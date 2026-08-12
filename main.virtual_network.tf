module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.20.0"
  count   = var.virtual_network_enabled ? 1 : 0

  location                = var.location
  parent_id               = local.resource_group_id
  address_space           = var.virtual_network_address_space
  bgp_community           = var.virtual_network_bgp_community
  ddos_protection_plan    = var.virtual_network_ddos_protection_plan
  diagnostic_settings     = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.virtual_network_diagnostic_settings
  dns_servers             = var.virtual_network_dns_servers
  enable_telemetry        = var.enable_telemetry
  enable_vm_protection    = var.virtual_network_enable_vm_protection
  encryption              = var.virtual_network_encryption
  extended_location       = var.virtual_network_extended_location
  flow_timeout_in_minutes = var.virtual_network_flow_timeout_in_minutes
  ipam_pools              = var.virtual_network_ipam_pools
  lock                    = var.virtual_network_lock
  name                    = coalesce(var.virtual_network_name, module.naming.resource_names.virtual_network)
  peerings = merge(
    var.hub_peering_enabled ? {
      hub = {
        name                               = module.naming.resource_names.peer_to_hub
        remote_virtual_network_resource_id = var.hub_virtual_network_resource_id
        allow_forwarded_traffic            = true
        allow_gateway_transit              = false
        use_remote_gateways                = false
        create_reverse_peering             = true
        reverse_name                       = module.naming.resource_names.peer_from_hub
        reverse_allow_forwarded_traffic    = true
        reverse_allow_gateway_transit      = true
      }
    } : {},
    var.alz_platform_landing_zone_peer_to_hub_enabled ? {
      alz_hub = {
        name                               = coalesce(var.alz_platform_landing_zone_peer_to_hub_name, module.naming.resource_names.alz_peer_to_hub)
        remote_virtual_network_resource_id = var.alz_platform_landing_zone_peering_hub_virtual_network_id
        allow_forwarded_traffic            = true
        allow_gateway_transit              = false
        use_remote_gateways                = false
        create_reverse_peering             = true
        reverse_name                       = coalesce(var.alz_platform_landing_zone_peer_from_hub_name, module.naming.resource_names.alz_peer_from_hub)
        reverse_allow_forwarded_traffic    = true
        reverse_allow_gateway_transit      = true
      }
    } : {}
  )
  retry            = var.virtual_network_retry
  role_assignments = var.virtual_network_role_assignments
  subnets          = local.subnets
  tags             = var.tags
  timeouts         = var.virtual_network_timeouts
}
