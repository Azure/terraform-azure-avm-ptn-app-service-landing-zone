module "app_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "2.0.1"
  count   = var.app_service_plan_resource_id == null ? 1 : 0

  location                   = var.location
  name                       = coalesce(var.app_service_plan_name, "asp-${var.name}")
  os_type                    = var.app_service_plan_os_type
  parent_id                  = local.resource_group_id
  app_service_environment_id = local.app_service_environment_id
  enable_telemetry           = var.enable_telemetry
  sku_name                   = local.effective_sku_name
  tags                       = var.tags
  worker_count               = var.app_service_plan_worker_count
  zone_balancing_enabled     = var.app_service_plan_zone_balancing_enabled
}
