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
  name             = "${module.naming.resource_group.name_unique}-alz"
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
# Hub Network - simulates the ALZ connectivity subscription hub VNet
# ------------------------------------------------------------------

module "hub_virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1"

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
  zones               = []
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
  zones               = []
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
  firewall_zones     = []
  ip_configurations = {
    default = {
      name                 = "fw-ipconfig"
      public_ip_address_id = module.firewall_public_ip.public_ip_id
      subnet_id            = module.hub_virtual_network.subnets["AzureFirewallSubnet"].resource_id
    }
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
  enable_telemetry                                                       = var.enable_telemetry
  log_analytics_workspace_resource_id                                    = module.log_analytics_workspace.resource_id
  # Networking
  virtual_network_address_space = ["10.1.0.0/16"]
  # Web Apps
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
      deployment_slots = {
        uat = {
          name = "uat"
          site_config = {
            application_stack = {
              node = {
                node_version = "20-lts"
              }
            }
          }
        }
        staging = {
          name = "staging"
          site_config = {
            application_stack = {
              node = {
                node_version = "20-lts"
              }
            }
          }
        }
      }
    }
  }
}
