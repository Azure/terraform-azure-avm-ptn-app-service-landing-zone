locals {
  # Route table ID for egress lockdown
  route_table_id = var.egress_lockdown_enabled && var.firewall_private_ip != null ? module.route_table[0].resource_id : null
  # Subnets to create in the virtual network
  subnets = merge(
    # App Service VNet integration subnet (when NOT using ASE)
    !var.app_service_environment_enabled && var.app_service_subnet_resource_id == null ? {
      app_service = {
        name             = "snet-app-service"
        address_prefixes = [var.app_service_subnet_address_prefix]
        route_table = local.route_table_id != null ? {
          id = local.route_table_id
        } : null
        delegations = [
          {
            name = "Microsoft.Web.serverFarms"
            service_delegation = {
              name = "Microsoft.Web/serverFarms"
            }
          }
        ]
      }
    } : {},
    # ASE subnet (when using ASE)
    var.app_service_environment_enabled && var.app_service_environment_subnet_resource_id == null ? {
      app_service_environment = {
        name             = "snet-ase"
        address_prefixes = [var.app_service_environment_subnet_address_prefix]
        route_table = local.route_table_id != null ? {
          id = local.route_table_id
        } : null
        delegations = [
          {
            name = "Microsoft.Web.hostingEnvironments"
            service_delegation = {
              name = "Microsoft.Web/hostingEnvironments"
            }
          }
        ]
      }
    } : {},
    # Private endpoint subnet
    var.private_endpoint_subnet_resource_id == null ? {
      private_endpoints = {
        name                              = "snet-private-endpoints"
        address_prefixes                  = [var.private_endpoint_subnet_address_prefix]
        private_endpoint_network_policies = "Enabled"
      }
    } : {},
    # Azure Bastion subnet (when bastion is enabled and no BYO subnet)
    local.bastion_host_effectively_enabled && var.bastion_host_subnet_resource_id == null ? {
      AzureBastionSubnet = {
        name             = "AzureBastionSubnet"
        address_prefixes = [var.bastion_host_subnet_address_prefix]
      }
    } : {},
    # Application Gateway subnet (when App Gateway is enabled and no BYO subnet)
    var.application_gateway_enabled && var.application_gateway_subnet_resource_id == null ? {
      application_gateway = {
        name             = "snet-agw"
        address_prefixes = [var.application_gateway_subnet_address_prefix]
      }
    } : {}
  )
}
