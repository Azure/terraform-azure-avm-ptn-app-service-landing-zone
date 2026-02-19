module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1"
  count   = var.virtual_network_enabled && var.virtual_network_resource_id == null ? 1 : 0

  location         = var.location
  parent_id        = local.resource_group_id
  address_space    = var.virtual_network_address_space
  enable_telemetry = var.enable_telemetry
  name             = coalesce(var.virtual_network_name, "vnet-${var.name}")
  peerings = var.hub_peering_enabled && var.hub_virtual_network_resource_id != null ? {
    hub = {
      name                               = "peer-to-hub"
      remote_virtual_network_resource_id = var.hub_virtual_network_resource_id
      allow_forwarded_traffic            = true
      allow_gateway_transit              = false
      use_remote_gateways                = false
      create_reverse_peering             = true
      reverse_name                       = "peer-to-spoke-${var.name}"
      reverse_allow_forwarded_traffic    = true
      reverse_allow_gateway_transit      = true
    }
  } : {}
  subnets = local.subnets
  tags    = var.tags
}
