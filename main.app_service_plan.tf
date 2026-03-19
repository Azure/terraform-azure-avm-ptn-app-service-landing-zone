module "app_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "2.0.1"
  count   = var.app_service_plan_enabled ? 1 : 0

  location                   = var.location
  name                       = coalesce(var.app_service_plan_name, module.naming.resource_names.app_service_plan)
  os_type                    = var.app_service_plan_os_type
  parent_id                  = local.resource_group_id
  app_service_environment_id = local.app_service_environment_id
  diagnostic_settings        = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.app_service_plan_diagnostic_settings
  enable_telemetry           = var.enable_telemetry
  install_scripts            = var.app_service_plan_install_scripts != null ? concat(var.app_service_plan_install_scripts, local.managed_instance_install_scripts_config) : (length(local.managed_instance_install_scripts_config) > 0 ? local.managed_instance_install_scripts_config : null)
  lock                       = var.app_service_plan_lock
  managed_identities = {
    system_assigned = var.app_service_plan_managed_identities.system_assigned
    user_assigned_resource_ids = setunion(
      var.app_service_plan_managed_identities.user_assigned_resource_ids,
      var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? [module.managed_instance_managed_identity[0].resource_id] : []
    )
  }
  maximum_elastic_worker_count = var.app_service_plan_maximum_elastic_worker_count
  per_site_scaling_enabled     = var.app_service_plan_per_site_scaling_enabled
  plan_default_identity = var.app_service_plan_plan_default_identity != null ? var.app_service_plan_plan_default_identity : (
    var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? {
      identity_type                      = "UserAssigned"
      user_assigned_identity_resource_id = module.managed_instance_managed_identity[0].resource_id
    } : null
  )
  premium_plan_auto_scale_enabled = var.app_service_plan_premium_plan_auto_scale_enabled
  rdp_enabled                     = var.app_service_plan_rdp_enabled
  registry_adapters               = var.app_service_plan_registry_adapters != null ? concat(var.app_service_plan_registry_adapters, local.managed_instance_registry_adapters_config) : (length(local.managed_instance_registry_adapters_config) > 0 ? local.managed_instance_registry_adapters_config : null)
  retry                           = var.app_service_plan_retry
  role_assignments                = var.app_service_plan_role_assignments
  sku_name                        = local.effective_sku_name
  storage_mounts                  = var.app_service_plan_storage_mounts != null ? concat(var.app_service_plan_storage_mounts, local.managed_instance_storage_mounts_config) : (length(local.managed_instance_storage_mounts_config) > 0 ? local.managed_instance_storage_mounts_config : null)
  tags                            = var.tags
  timeouts                        = var.app_service_plan_timeouts
  virtual_network_subnet_id       = var.app_service_plan_virtual_network_subnet_id != null ? var.app_service_plan_virtual_network_subnet_id : (var.app_service_plan_os_type == "WindowsManagedInstance" ? local.app_service_subnet_id : null)
  worker_count                    = var.app_service_plan_worker_count
  zone_balancing_enabled          = var.app_service_plan_zone_balancing_enabled
}
