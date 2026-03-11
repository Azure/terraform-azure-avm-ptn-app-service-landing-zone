module "alz_route_table" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.4.1"
  count   = var.alz_platform_landing_zone_route_table_resource_id == null && var.alz_platform_landing_zone_route_table_enabled ? 1 : 0

  location                      = var.location
  name                          = coalesce(var.alz_platform_landing_zone_route_table_name, module.naming.resource_names.alz_route_table)
  resource_group_name           = local.resource_group_name
  bgp_route_propagation_enabled = false
  enable_telemetry              = var.enable_telemetry
  routes = merge(
    var.alz_platform_landing_zone_route_table_hub_virtual_appliance_ip_address != null ? {
      default_route = {
        name                   = "defaultRoute"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = var.alz_platform_landing_zone_route_table_hub_virtual_appliance_ip_address
      }
    } : {},
    var.alz_platform_landing_zone_route_table_hub_virtual_appliance_ip_address != null ? {
      for idx, prefix in var.alz_platform_landing_zone_route_table_address_spaces : "address_space_${idx}" => {
        name                   = "route-address-space-${idx}"
        address_prefix         = prefix
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = var.alz_platform_landing_zone_route_table_hub_virtual_appliance_ip_address
      }
    } : {}
  )
  tags = var.tags
}
