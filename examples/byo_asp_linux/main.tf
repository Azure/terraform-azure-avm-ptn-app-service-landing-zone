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

# --- Pre-existing (BYO) resources ---

# Virtual Network with subnets
resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "app_service" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "snet-app-service"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  delegation {
    name = "Microsoft.Web-serverFarms"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

# App Service Plan
resource "azurerm_service_plan" "this" {
  location               = azurerm_resource_group.this.location
  name                   = module.naming.app_service_plan.name_unique
  os_type                = "Linux"
  resource_group_name    = azurerm_resource_group.this.name
  sku_name               = "P1v3"
  worker_count           = 3
  zone_balancing_enabled = true
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "web" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "web" {
  name                  = "vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.web.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

# --- Module deployment using BYO resources ---

module "test" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.app_service.name_unique
  resource_group_name = azurerm_resource_group.this.name
  # BYO App Service Plan
  app_service_plan_resource_id   = azurerm_service_plan.this.id
  app_service_subnet_resource_id = azurerm_subnet.app_service.id
  enable_telemetry               = var.enable_telemetry
  # Front Door (created by the module)
  front_door_enabled = true
  # BYO Private DNS Zone
  private_dns_zone_web_resource_id    = azurerm_private_dns_zone.web.id
  private_endpoint_subnet_resource_id = azurerm_subnet.private_endpoints.id
  # BYO Virtual Network and subnets
  virtual_network_resource_id = azurerm_virtual_network.this.id
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
      deployment_slots = {
        dev = {
          name = "dev"
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
        prod = {
          name = "prod"
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
