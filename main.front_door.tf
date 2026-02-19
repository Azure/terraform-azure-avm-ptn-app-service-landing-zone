module "front_door" {
  source  = "Azure/avm-res-cdn-profile/azurerm"
  version = "0.1.9"
  count   = var.front_door_enabled && var.front_door_resource_id == null && length(var.web_apps) > 0 ? 1 : 0

  location                     = "Global"
  name                         = coalesce(var.front_door_name, "afd-${var.name}")
  resource_group_name          = var.resource_group_name
  enable_telemetry             = var.enable_telemetry
  front_door_endpoints         = local.front_door_endpoints
  front_door_firewall_policies = local.front_door_firewall_policies
  front_door_origin_groups     = local.front_door_origin_groups
  front_door_origins           = local.front_door_origins
  front_door_routes            = local.front_door_routes
  front_door_security_policies = local.front_door_security_policies
  sku                          = var.front_door_sku
  tags                         = var.tags
}
