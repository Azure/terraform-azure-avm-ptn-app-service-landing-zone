module "container_registry" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.6.0"
  count   = local.container_registry_effectively_enabled ? 1 : 0

  location                   = var.location
  name                       = coalesce(var.container_registry_name, module.naming.resource_names.container_registry)
  resource_group_name        = local.resource_group_name
  admin_enabled              = false
  diagnostic_settings        = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.container_registry_diagnostic_settings
  enable_telemetry           = var.enable_telemetry
  lock                       = var.container_registry_lock
  network_rule_bypass_option = "AzureServices"
  network_rule_set           = var.container_registry_network_rule_set
  private_endpoints = local.virtual_network_enabled ? {
    default = {
      subnet_resource_id            = local.private_endpoint_subnet_id
      private_dns_zone_resource_ids = local.private_dns_zone_container_registry_id != null ? toset([local.private_dns_zone_container_registry_id]) : toset([])
    }
  } : {}
  public_network_access_enabled = local.virtual_network_enabled ? false : var.container_registry_public_network_access_enabled
  role_assignments = merge(
    var.container_registry_role_assignments,
    local.container_registry_acr_pull_role_assignments
  )
  sku                     = var.container_registry_sku
  tags                    = try(coalesce(var.container_registry_tags, var.tags), {})
  zone_redundancy_enabled = var.container_registry_zone_redundancy_enabled
}
