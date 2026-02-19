locals {
  # App Service Environment
  app_service_environment_id = var.app_service_environment_resource_id != null ? var.app_service_environment_resource_id : (
    var.app_service_environment_enabled ? module.app_service_environment[0].resource_id : null
  )
  app_service_environment_subnet_id = var.app_service_environment_subnet_resource_id != null ? var.app_service_environment_subnet_resource_id : (
    var.virtual_network_enabled && var.virtual_network_resource_id == null && var.app_service_environment_enabled ? (
      module.virtual_network[0].subnets["app_service_environment"].resource_id
    ) : null
  )
  # App Service Plan ID
  app_service_plan_id = var.app_service_plan_resource_id != null ? var.app_service_plan_resource_id : module.app_service_plan[0].resource_id
  # Subnet IDs
  app_service_subnet_id = var.app_service_subnet_resource_id != null ? var.app_service_subnet_resource_id : (
    var.virtual_network_enabled && var.virtual_network_resource_id == null && !var.app_service_environment_enabled ? (
      module.virtual_network[0].subnets["app_service"].resource_id
    ) : null
  )
  # Private DNS Zone
  create_private_dns_zone_web = var.private_dns_zones_enabled && var.private_dns_zone_web_resource_id == null && local.virtual_network_enabled
  # App Service Plan - auto-adjust SKU for ASE (Isolated tier required)
  effective_sku_name = var.app_service_environment_enabled && !startswith(var.app_service_plan_sku_name, "I") ? "I1v2" : var.app_service_plan_sku_name
  private_dns_zone_web_id = var.private_dns_zone_web_resource_id != null ? var.private_dns_zone_web_resource_id : (
    local.create_private_dns_zone_web ? module.private_dns_zone_web[0].resource_id : null
  )
  private_endpoint_subnet_id = var.private_endpoint_subnet_resource_id != null ? var.private_endpoint_subnet_resource_id : (
    var.virtual_network_enabled && var.virtual_network_resource_id == null ? (
      module.virtual_network[0].subnets["private_endpoints"].resource_id
    ) : null
  )
  resource_group_id = "/subscriptions/${data.azapi_client_config.this.subscription_id}/resourceGroups/${var.resource_group_name}"
  # Virtual networking
  virtual_network_enabled = var.virtual_network_enabled || var.virtual_network_resource_id != null
  virtual_network_id = var.virtual_network_resource_id != null ? var.virtual_network_resource_id : (
    var.virtual_network_enabled ? module.virtual_network[0].resource_id : null
  )
  # Web App OS type - WindowsManagedInstance plans host Windows web apps
  web_app_default_os_type = var.app_service_plan_os_type == "WindowsManagedInstance" ? "Windows" : var.app_service_plan_os_type
}
