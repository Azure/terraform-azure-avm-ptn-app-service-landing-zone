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
  name             = "${module.naming.resource_group.name_unique}-ase-windows"
  enable_telemetry = var.enable_telemetry
}

# App Service Environment v3 - Windows with .NET 8
# ASE provides a fully isolated, dedicated hosting environment.
# The App Service Plan SKU is automatically set to Isolated v2 tier.
module "test" {
  source = "../../"

  location            = module.resource_group.location
  name                = module.naming.app_service.name_unique
  resource_group_name = module.resource_group.name
  # Enable App Service Environment v3
  app_service_environment_enabled                      = true
  app_service_environment_internal_load_balancing_mode = "Web, Publishing"
  app_service_environment_zone_redundancy_enabled      = true
  app_service_plan_os_type                             = "Windows"
  app_service_plan_sku_name                            = "I1v2"
  app_service_plan_worker_count                        = 3
  app_service_plan_zone_balancing_enabled              = true
  enable_telemetry                                     = var.enable_telemetry
  front_door_enabled                                   = true
  private_dns_zones_enabled                            = true
  virtual_network_enabled                              = true
  web_apps = {
    app1 = {
      name = module.naming.app_service.name_unique
      site_config = {
        application_stack = {
          dotnet = {
            dotnet_version = "v8.0"
            current_stack  = "dotnet"
          }
        }
      }
      managed_identities = {
        system_assigned = true
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
        stage = {
          name = "stage"
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
