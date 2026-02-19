locals {
  # Subnets to create in the virtual network
  subnets = merge(
    # App Service VNet integration subnet (when NOT using ASE)
    !var.app_service_environment_enabled && var.app_service_subnet_resource_id == null ? {
      app_service = {
        name             = "snet-app-service"
        address_prefixes = [var.app_service_subnet_address_prefix]
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
    } : {}
  )
}
