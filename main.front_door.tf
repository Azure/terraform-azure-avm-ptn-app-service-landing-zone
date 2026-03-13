module "front_door" {
  source  = "Azure/avm-res-cdn-profile/azurerm"
  version = "0.1.9"
  count   = var.front_door_enabled && length(var.web_apps) > 0 ? 1 : 0

  location            = "Global"
  name                = coalesce(var.front_door_name, module.naming.resource_names.front_door)
  resource_group_name = local.resource_group_name
  # CDN resources
  cdn_endpoint_custom_domains = var.front_door_cdn_endpoint_custom_domains
  cdn_endpoints               = var.front_door_cdn_endpoints
  # Management
  diagnostic_settings = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.front_door_diagnostic_settings
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
  front_door_security_policies = {} # Managed outside the CDN module to work around for_each/try() issue
  lock                         = var.front_door_lock
  managed_identities           = var.front_door_managed_identities
  metric_alerts                = var.front_door_metric_alerts
  response_timeout_seconds     = var.front_door_response_timeout_seconds
  role_assignments             = var.front_door_role_assignments
  sku                          = var.front_door_sku
  tags                         = var.tags
}

# Security policies are created outside the CDN module to work around a
# for_each/try() incompatibility in the CDN module (v0.1.9) with Terraform 1.12+.
resource "azapi_resource" "frontdoor_security_policy" {
  for_each = var.front_door_enabled && length(var.web_apps) > 0 ? merge(local.front_door_security_policies, var.front_door_additional_security_policies) : {}

  name      = each.value.name
  parent_id = module.front_door[0].resource_id
  type      = "Microsoft.Cdn/profiles/securityPolicies@2024-09-01"
  body = {
    properties = {
      parameters = {
        type = "WebApplicationFirewall"
        wafPolicy = {
          id = module.front_door[0].frontdoor_firewall_policies[each.value.firewall.front_door_firewall_policy_key].id
        }
        associations = [
          {
            domains = [
              for id in concat(
                [for ep_key in each.value.firewall.association.endpoint_keys : module.front_door[0].frontdoor_endpoints[ep_key].id],
                [for cd_key in try(each.value.firewall.association.domain_keys, []) : module.front_door[0].frontdoor_custom_domains[cd_key].id]
                ) : {
                id = id
              }
            ]
            patternsToMatch = each.value.firewall.association.patterns_to_match
          }
        ]
      }
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Auto-approve private endpoint connections from Front Door to web apps
data "azapi_resource_list" "front_door_web_app_private_endpoint_connections" {
  for_each               = local.front_door_private_link_enabled ? var.web_apps : {}
  type                   = "Microsoft.Web/sites/privateEndpointConnections@2024-04-01"
  parent_id              = module.web_app[each.key].resource_id
  response_export_values = ["*"]

  depends_on = [module.front_door]
}

resource "azapi_update_resource" "front_door_private_endpoint_approval" {
  for_each    = local.front_door_private_link_enabled ? var.web_apps : {}
  type        = "Microsoft.Web/sites/privateEndpointConnections@2024-04-01"
  resource_id = one([
    for conn in try(data.azapi_resource_list.front_door_web_app_private_endpoint_connections[each.key].output.value, []) :
    conn.id
    if try(conn.properties.privateLinkServiceConnectionState.description, "") == "Please approve this private link connection" ||
    try(conn.properties.privateLinkServiceConnectionState.description, "") == "Auto-approved for Front Door"
  ])
  body = {
    properties = {
      privateLinkServiceConnectionState = {
        status          = "Approved"
        description     = "Auto-approved for Front Door"
        actionsRequired = "None"
      }
    }
  }
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
