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

# App Service Plan - Linux with .NET 10 and Application Gateway (WAF_v2)
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
      name = module.naming.app_service.name_unique
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
