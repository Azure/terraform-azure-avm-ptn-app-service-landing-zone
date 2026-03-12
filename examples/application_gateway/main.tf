terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {}
}

resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"
}

module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.2"

  location         = local.azure_regions[random_integer.region_index.result]
  name             = "${module.naming.resource_group.name_unique}-appgw"
  enable_telemetry = var.enable_telemetry
}

module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"

  location            = module.resource_group.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry
}

# ------------------------------------------------------------------
# Upload the sample app zip to a public storage account so the
# extensions/zipdeploy ARM API can fetch it via HTTPS URL.
# ------------------------------------------------------------------

resource "azurerm_storage_account" "zip_deploy" {
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "zip_deploy" {
  name                 = "zip-deploy"
  storage_account_id   = azurerm_storage_account.zip_deploy.id
}

resource "azurerm_storage_blob" "zip_deploy" {
  name                   = "app.zip"
  storage_account_name   = azurerm_storage_account.zip_deploy.name
  storage_container_name = azurerm_storage_container.zip_deploy.name
  type                   = "Block"
  source                 = "${path.module}/app.zip"
  content_md5            = filemd5("${path.module}/app.zip")
}

data "azurerm_storage_account_blob_container_sas" "zip_deploy" {
  connection_string = azurerm_storage_account.zip_deploy.primary_connection_string
  container_name    = azurerm_storage_container.zip_deploy.name
  start             = "2024-01-01T00:00:00Z"
  expiry            = "2099-01-01T00:00:00Z"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}

# App Service Plan - Linux with .NET 10 and Application Gateway (WAF_v2).
# The module auto-creates a self-signed TLS certificate in Key Vault for HTTPS.
# For production, provide your own certificate via application_gateway_ssl_certificates.
module "test" {
  source = "../../"

  location                            = module.resource_group.location
  parent_id                           = module.resource_group.resource_id
  application_gateway_enabled         = true
  enable_telemetry                    = var.enable_telemetry
  front_door_enabled                  = false
  log_analytics_workspace_resource_id = module.log_analytics_workspace.resource_id
  web_apps = {
    app1 = {
      name            = module.naming.app_service.name_unique
      zip_deploy_file = nonsensitive("${azurerm_storage_blob.zip_deploy.url}${data.azurerm_storage_account_blob_container_sas.zip_deploy.sas}")
      site_config = {
        application_stack = {
          dotnet = {
            dotnet_version = "v10.0"
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
                dotnet_version = "v10.0"
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
                dotnet_version = "v10.0"
                current_stack  = "dotnet"
              }
            }
          }
        }
      }
    }
  }
}
