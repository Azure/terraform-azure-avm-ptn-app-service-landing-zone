terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    storage {
      data_plane_available = false
    }
  }
  storage_use_azuread = true
}

data "azurerm_client_config" "current" {}

resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.3"
}

module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.4.0"

  location         = local.azure_regions[random_integer.region_index.result]
  name             = "${module.naming.resource_group.name_unique}-byo-asp-linux"
  enable_telemetry = var.enable_telemetry
}

# Virtual Network with subnets
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.22.1"

  location         = module.resource_group.location
  parent_id        = module.resource_group.resource_id
  address_space    = ["10.0.0.0/16"]
  enable_telemetry = var.enable_telemetry
  name             = module.naming.virtual_network.name_unique
  subnets = {
    app_service = {
      name             = "snet-app-service"
      address_prefixes = ["10.0.0.0/24"]
      delegations = [
        {
          name = "Microsoft.Web-serverFarms"
          service_delegation = {
            name    = "Microsoft.Web/serverFarms"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
          }
        }
      ]
    }
    private_endpoints = {
      name             = "snet-private-endpoints"
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

# App Service Plan
module "app_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "2.0.8"

  location               = module.resource_group.location
  name                   = module.naming.app_service_plan.name_unique
  os_type                = "Linux"
  parent_id              = module.resource_group.resource_id
  enable_telemetry       = var.enable_telemetry
  sku_name               = "P1v3"
  worker_count           = 3
  zone_balancing_enabled = true
}

# Private DNS Zone
module "private_dns_zone_web" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"

  domain_name      = "privatelink.azurewebsites.net"
  parent_id        = module.resource_group.resource_id
  enable_telemetry = var.enable_telemetry
  virtual_network_links = {
    vnet_link = {
      name               = "vnet-link"
      virtual_network_id = module.virtual_network.resource_id
    }
  }
}

# ------------------------------------------------------------------
# Upload the sample app zip to a public storage account so the
# extensions/zipdeploy ARM API can fetch it via HTTPS URL.
# ------------------------------------------------------------------

module "storage_account_zip_deploy" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.8.1"

  location                 = module.resource_group.location
  name                     = "${module.naming.storage_account.name_unique}test001"
  resource_group_name      = module.resource_group.name
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  containers = {
    zip-deploy = {
      name = "zip-deploy"
      role_assignments = {
        storage_blob_data_contributor = {
          role_definition_id_or_name = "Storage Blob Data Contributor"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    }
  }
  enable_telemetry              = var.enable_telemetry
  network_rules                 = null
  public_network_access_enabled = true
  shared_access_key_enabled     = true
}

resource "time_sleep" "wait_for_storage_account" {
  create_duration = "30s"

  depends_on = [module.storage_account_zip_deploy]
}

resource "azurerm_storage_blob" "zip_deploy" {
  name                   = "app.zip"
  type                   = "Block"
  content_md5            = filemd5("${path.module}/app.zip")
  source                 = "${path.module}/app.zip"
  storage_account_name   = module.storage_account_zip_deploy.name
  storage_container_name = "zip-deploy"

  depends_on = [time_sleep.wait_for_storage_account]
}

data "azurerm_storage_account_blob_container_sas" "zip_deploy" {
  connection_string = module.storage_account_zip_deploy.resource.primary_connection_string
  container_name    = "zip-deploy"
  expiry            = "2099-01-01T00:00:00Z"
  start             = "2024-01-01T00:00:00Z"

  permissions {
    add    = false
    create = false
    delete = false
    list   = false
    read   = true
    write  = false
  }
}

# --- Module deployment using BYO resources ---

module "test" {
  source = "../../"

  location  = module.resource_group.location
  parent_id = module.resource_group.resource_id
  # BYO App Service Plan - disable creation, provide existing resource ID
  app_service_plan_enabled       = false
  app_service_plan_resource_id   = module.app_service_plan.resource_id
  app_service_subnet_resource_id = module.virtual_network.subnets["app_service"].resource_id
  enable_telemetry               = var.enable_telemetry
  # Front Door (created by the module)
  front_door_enabled                             = true
  log_analytics_workspace_internet_query_enabled = true
  # BYO Private DNS Zone - disable creation, provide existing resource ID
  private_dns_zone_web_resource_id    = module.private_dns_zone_web.resource_id
  private_dns_zones_enabled           = false
  private_endpoint_subnet_resource_id = module.virtual_network.subnets["private_endpoints"].resource_id
  # BYO Virtual Network - disable creation, provide existing resource ID
  virtual_network_enabled     = false
  virtual_network_resource_id = module.virtual_network.resource_id
  web_apps = {
    app1 = {
      zip_deploy_file = nonsensitive("${azurerm_storage_blob.zip_deploy.url}${data.azurerm_storage_account_blob_container_sas.zip_deploy.sas}")
      app_settings = {
        SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
      }
      site_config = {
        application_stack = {
          dotnet = {
            dotnet_version = "10.0"
            current_stack  = "dotnet"
          }
        }
      }
      managed_identities = {
        system_assigned = true
      }
      private_endpoints = {
        default = {
          subnet_resource_id            = module.virtual_network.subnets["private_endpoints"].resource_id
          private_dns_zone_resource_ids = toset([module.private_dns_zone_web.resource_id])
        }
      }
      deployment_slots = {
        uat = {
          name = "uat"
          site_config = {
            application_stack = {
              dotnet = {
                dotnet_version = "10.0"
                current_stack  = "dotnet"
              }
            }
          }
        }
        staging = {
          name = "staging"
          site_config = {
            application_stack = {
              dotnet = {
                dotnet_version = "10.0"
                current_stack  = "dotnet"
              }
            }
          }
        }
      }
    }
  }
}
