module "route_table" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.4.1"
  count   = var.egress_lockdown_enabled && var.firewall_private_ip != null ? 1 : 0

  location                      = var.location
  name                          = coalesce(var.route_table_name, "rt-${var.name}")
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = var.route_table_bgp_route_propagation_enabled
  enable_telemetry              = var.enable_telemetry
  routes = {
    default_route = {
      name                   = "defaultRoute"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  }
  tags = var.tags
}
