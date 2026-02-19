module "web_app" {
  source   = "Azure/avm-res-web-site/azurerm"
  version  = "0.21.0"
  for_each = var.web_apps

  location                 = var.location
  name                     = each.value.name
  parent_id                = local.resource_group_id
  service_plan_resource_id = local.app_service_plan_id
  diagnostic_settings      = each.value.diagnostic_settings
  enable_telemetry         = coalesce(each.value.enable_telemetry, var.enable_telemetry)
  https_only               = true
  kind                     = each.value.kind
  lock                     = each.value.lock
  managed_identities       = each.value.managed_identities
  os_type                  = coalesce(each.value.os_type, local.web_app_default_os_type)
  private_endpoints = local.virtual_network_enabled ? {
    default = {
      subnet_resource_id            = local.private_endpoint_subnet_id
      private_dns_zone_resource_ids = local.private_dns_zone_web_id != null ? toset([local.private_dns_zone_web_id]) : toset([])
    }
  } : {}
  public_network_access_enabled = each.value.public_network_access_enabled
  role_assignments              = each.value.role_assignments
  site_config                   = each.value.site_config
  tags                          = merge(coalesce(var.tags, {}), coalesce(each.value.tags, {}))
  virtual_network_subnet_id     = var.app_service_environment_enabled ? null : local.app_service_subnet_id
}
