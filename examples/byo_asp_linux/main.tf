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
  name             = "${module.naming.resource_group.name_unique}-byo-asp-linux"
  enable_telemetry = var.enable_telemetry
}

# --- Pre-existing (BYO) resources ---

module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"

  location            = module.resource_group.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry
}

# Virtual Network with subnets
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1"

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
  version = "2.0.1"

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
  front_door_enabled                  = true
  log_analytics_workspace_resource_id = module.log_analytics_workspace.resource_id
  # BYO Private DNS Zone - disable creation, provide existing resource ID
  private_dns_zone_web_resource_id    = module.private_dns_zone_web.resource_id
  private_dns_zones_enabled           = false
  private_endpoint_subnet_resource_id = module.virtual_network.subnets["private_endpoints"].resource_id
  # BYO Virtual Network - disable creation, provide existing resource ID
  virtual_network_enabled     = false
  virtual_network_resource_id = module.virtual_network.resource_id
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
