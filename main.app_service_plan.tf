module "app_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "2.0.1"
  count   = var.app_service_plan_resource_id == null ? 1 : 0

  location                       = var.location
  name                           = coalesce(var.app_service_plan_name, "asp-${var.name}")
  os_type                        = var.app_service_plan_os_type
  parent_id                      = local.resource_group_id
  app_service_environment_id     = local.app_service_environment_id
  diagnostic_settings            = var.app_service_plan_diagnostic_settings
  enable_telemetry               = var.enable_telemetry
  install_scripts                = var.app_service_plan_install_scripts
  lock                           = var.app_service_plan_lock
  managed_identities             = var.app_service_plan_managed_identities
  maximum_elastic_worker_count   = var.app_service_plan_maximum_elastic_worker_count
  per_site_scaling_enabled       = var.app_service_plan_per_site_scaling_enabled
  plan_default_identity          = var.app_service_plan_plan_default_identity
  premium_plan_auto_scale_enabled = var.app_service_plan_premium_plan_auto_scale_enabled
  rdp_enabled                    = var.app_service_plan_rdp_enabled
  registry_adapters              = var.app_service_plan_registry_adapters
  retry                          = var.app_service_plan_retry
  role_assignments               = var.app_service_plan_role_assignments
  sku_name                       = local.effective_sku_name
  storage_mounts                 = var.app_service_plan_storage_mounts
  tags                           = var.tags
  timeouts                       = var.app_service_plan_timeouts
  virtual_network_subnet_id      = var.app_service_plan_virtual_network_subnet_id
  worker_count                   = var.app_service_plan_worker_count
  zone_balancing_enabled         = var.app_service_plan_zone_balancing_enabled
}
