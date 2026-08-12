terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
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
  name             = "${module.naming.resource_group.name_unique}-alz"
  enable_telemetry = var.enable_telemetry
}

# ------------------------------------------------------------------
# Hub Network - simulates the ALZ connectivity subscription hub VNet
# ------------------------------------------------------------------

module "hub_virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.20.0"

  location         = module.resource_group.location
  parent_id        = module.resource_group.resource_id
  address_space    = ["10.100.0.0/16"]
  enable_telemetry = var.enable_telemetry
  name             = "vnet-hub-${module.naming.virtual_network.name_unique}"
  subnets = {
    AzureFirewallSubnet = {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.100.0.0/26"]
    }
    AzureFirewallManagementSubnet = {
      name             = "AzureFirewallManagementSubnet"
      address_prefixes = ["10.100.0.64/26"]
    }
  }
}

# ------------------------------------------------------------------
# Azure Firewall (Basic SKU) in the hub network
# ------------------------------------------------------------------

# Public IP for firewall traffic
module "firewall_public_ip" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "0.2.1"

  location            = module.resource_group.location
  name                = "pip-fw-${module.naming.public_ip.name_unique}"
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
  enable_telemetry    = var.enable_telemetry
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

# Public IP for firewall management traffic (required for Basic SKU)
module "firewall_management_public_ip" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "0.2.1"

  location            = module.resource_group.location
  name                = "pip-fw-mgmt-${module.naming.public_ip.name_unique}"
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
  enable_telemetry    = var.enable_telemetry
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

# Firewall Policy (Basic SKU)
module "firewall_policy" {
  source  = "Azure/avm-res-network-firewallpolicy/azurerm"
  version = "0.3.4"

  location            = module.resource_group.location
  name                = "fwpol-${module.naming.firewall.name_unique}"
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry
  firewall_policy_sku = "Basic"
}

# Azure Firewall (Basic SKU)
module "firewall" {
  source  = "Azure/avm-res-network-azurefirewall/azurerm"
  version = "0.4.0"

  firewall_sku_name   = "AZFW_VNet"
  firewall_sku_tier   = "Basic"
  location            = module.resource_group.location
  name                = "fw-${module.naming.firewall.name_unique}"
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry
  firewall_management_ip_configuration = {
    name                 = "fw-mgmt-ipconfig"
    public_ip_address_id = module.firewall_management_public_ip.public_ip_id
    subnet_id            = module.hub_virtual_network.subnets["AzureFirewallManagementSubnet"].resource_id
  }
  firewall_policy_id = module.firewall_policy.resource_id
  firewall_zones     = ["1", "2", "3"]
  ip_configurations = {
    default = {
      name                 = "fw-ipconfig"
      public_ip_address_id = module.firewall_public_ip.public_ip_id
      subnet_id            = module.hub_virtual_network.subnets["AzureFirewallSubnet"].resource_id
    }
  }
}

# ------------------------------------------------------------------
# Upload the sample app zip to a public storage account so the
# extensions/zipdeploy ARM API can fetch it via HTTPS URL.
# ------------------------------------------------------------------

module "storage_account_zip_deploy" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.7.4"

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
  storage_account_name   = module.storage_account_zip_deploy.name
  storage_container_name = "zip-deploy"
  type                   = "Block"
  content_md5            = filemd5("${path.module}/app.zip")
  source                 = "${path.module}/app.zip"

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

# ------------------------------------------------------------------
# App Service Landing Zone (spoke) with ALZ integration
# ------------------------------------------------------------------

module "test" {
  source = "../../"

  location  = module.resource_group.location
  parent_id = module.resource_group.resource_id
  # ALZ hub peering - bi-directional peering to the hub VNet
  alz_platform_landing_zone_peer_to_hub_enabled            = true
  alz_platform_landing_zone_peering_hub_virtual_network_id = module.hub_virtual_network.resource_id
  # Route hub network address space through the firewall as well
  alz_platform_landing_zone_route_table_address_spaces = ["10.100.0.0/16"]
  # ALZ route table - routes internet-bound traffic through the hub firewall
  alz_platform_landing_zone_route_table_enabled                          = true
  alz_platform_landing_zone_route_table_hub_virtual_appliance_ip_address = module.firewall.resource.ip_configuration[0].private_ip_address
  app_service_subnet_address_prefix                                      = "10.1.0.0/24"
  enable_telemetry                                                       = var.enable_telemetry
  log_analytics_workspace_internet_query_enabled                         = true
  private_endpoint_subnet_address_prefix                                 = "10.1.1.0/24"
  # Networking
  virtual_network_address_space = ["10.1.0.0/16"]
  # Web Apps
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
