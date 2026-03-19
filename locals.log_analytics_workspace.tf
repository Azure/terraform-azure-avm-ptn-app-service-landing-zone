locals {
  create_private_dns_zone_agentsvc = var.private_dns_zones_enabled && var.virtual_network_enabled && local.log_analytics_workspace_creation_enabled && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  # AMPLS private DNS zones for LAW private endpoints
  create_private_dns_zone_monitor = var.private_dns_zones_enabled && var.virtual_network_enabled && local.log_analytics_workspace_creation_enabled && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  create_private_dns_zone_ods     = var.private_dns_zones_enabled && var.virtual_network_enabled && local.log_analytics_workspace_creation_enabled && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  create_private_dns_zone_oms     = var.private_dns_zones_enabled && var.virtual_network_enabled && local.log_analytics_workspace_creation_enabled && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  # Log Analytics Workspace
  log_analytics_workspace_creation_enabled = var.log_analytics_workspace_enabled && var.log_analytics_workspace_resource_id == null
  log_analytics_workspace_private_dns_zone_resource_ids = compact([
    local.create_private_dns_zone_monitor ? module.private_dns_zone_monitor[0].resource_id : "",
    local.create_private_dns_zone_oms ? module.private_dns_zone_oms[0].resource_id : "",
    local.create_private_dns_zone_ods ? module.private_dns_zone_ods[0].resource_id : "",
    local.create_private_dns_zone_agentsvc ? module.private_dns_zone_agentsvc[0].resource_id : "",
  ])
  log_analytics_workspace_resource_id = var.log_analytics_workspace_resource_id != null ? var.log_analytics_workspace_resource_id : (
    local.log_analytics_workspace_creation_enabled ? module.log_analytics_workspace[0].resource_id : null
  )
}
