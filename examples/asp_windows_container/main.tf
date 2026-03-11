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
  name             = "${module.naming.resource_group.name_unique}-asp-windows-container"
  enable_telemetry = var.enable_telemetry
}

# App Service Plan - Windows Container (custom Docker image)
# Windows Containers require Premium v3 or Isolated v2 SKUs.
module "test" {
  source = "../../"

  location                                = module.resource_group.location
  name                                    = module.naming.app_service.name_unique
  resource_group_name                     = module.resource_group.name
  app_service_plan_os_type                = "Windows"
  app_service_plan_sku_name               = "P1v3"
  app_service_plan_worker_count           = 3
  app_service_plan_zone_balancing_enabled = true
  enable_telemetry                        = var.enable_telemetry
  front_door_enabled                      = true
  private_dns_zones_enabled               = true
  virtual_network_enabled                 = true
  web_apps = {
    app1 = {
      name = module.naming.app_service.name_unique
      site_config = {
        windows_fx_version = "DOCKER|mcr.microsoft.com/dotnet/samples:aspnetapp"
      }
      managed_identities = {
        system_assigned = true
      }
      deployment_slots = {
        uat = {
          name = "uat"
          site_config = {
            windows_fx_version = "DOCKER|mcr.microsoft.com/dotnet/samples:aspnetapp"
          }
        }
        stage = {
          name = "stage"
          site_config = {
            windows_fx_version = "DOCKER|mcr.microsoft.com/dotnet/samples:aspnetapp"
          }
        }
      }
    }
  }
}
