module "front_door" {
  source  = "Azure/avm-res-cdn-profile/azurerm"
  version = "0.1.9"
  count   = var.front_door_enabled && var.front_door_resource_id == null && length(var.web_apps) > 0 ? 1 : 0

  location            = "Global"
  name                = coalesce(var.front_door_name, "afd-${var.name}")
  resource_group_name = var.resource_group_name
  # CDN resources
  cdn_endpoint_custom_domains = var.front_door_cdn_endpoint_custom_domains
  cdn_endpoints               = var.front_door_cdn_endpoints
  # Management
  diagnostic_settings = var.front_door_diagnostic_settings
  enable_telemetry    = var.enable_telemetry
  # Front Door resources - merge auto-generated locals with user overrides
  front_door_custom_domains    = var.front_door_custom_domains
  front_door_endpoints         = merge(local.front_door_endpoints, var.front_door_additional_endpoints)
  front_door_firewall_policies = merge(local.front_door_firewall_policies, var.front_door_additional_firewall_policies)
  front_door_origin_groups     = merge(local.front_door_origin_groups, var.front_door_additional_origin_groups)
  front_door_origins           = merge(local.front_door_origins, var.front_door_additional_origins)
  front_door_routes            = merge(local.front_door_routes, var.front_door_additional_routes)
  front_door_rule_sets         = var.front_door_rule_sets
  front_door_rules             = var.front_door_rules
  front_door_secrets           = var.front_door_secrets
  front_door_security_policies = merge(local.front_door_security_policies, var.front_door_additional_security_policies)
  lock                         = var.front_door_lock
  managed_identities           = var.front_door_managed_identities
  metric_alerts                = var.front_door_metric_alerts
  response_timeout_seconds     = var.front_door_response_timeout_seconds
  role_assignments             = var.front_door_role_assignments
  sku                          = var.front_door_sku
  tags                         = var.tags
}
