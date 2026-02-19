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

# Default deployment: Linux App Service Plan with a web app, VNet integration,
# private endpoints, private DNS, and Azure Front Door (Premium with WAF).
module "test" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.app_service.name_unique
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry
  # Azure Front Door Premium with WAF (defaults)
  front_door_enabled = true
  # Virtual network with default address space (10.0.0.0/16)
  virtual_network_enabled = true
  # A single Linux web app with system-assigned managed identity
  web_apps = {
    app1 = {
      name = module.naming.app_service.name_unique
      managed_identities = {
        system_assigned = true
      }
    }
  }
}
