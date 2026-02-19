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

resource "azurerm_resource_group" "this" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

# App Service Environment v3 - Linux
# ASE provides a fully isolated, dedicated hosting environment.
# The App Service Plan SKU is automatically set to Isolated v2 tier.
module "test" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.app_service.name_unique
  resource_group_name = azurerm_resource_group.this.name
  # Enable App Service Environment v3
  app_service_environment_enabled                      = true
  app_service_environment_internal_load_balancing_mode = "Web, Publishing"
  app_service_environment_zone_redundancy_enabled      = true
  app_service_plan_os_type                             = "Linux"
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
          node = {
            node_version = "20-lts"
          }
        }
      }
      managed_identities = {
        system_assigned = true
      }
    }
  }
}
