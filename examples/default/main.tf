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
  name             = "${module.naming.resource_group.name_unique}-default"
  enable_telemetry = var.enable_telemetry
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
  create_duration = "60s"

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

# Default deployment: Linux App Service Plan with a web app, VNet integration,
# private endpoints, private DNS, and Azure Front Door (Premium with WAF).
module "test" {
  source = "../../"

  location                                       = module.resource_group.location
  parent_id                                      = module.resource_group.resource_id
  enable_telemetry                               = var.enable_telemetry
  log_analytics_workspace_internet_query_enabled = true
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
