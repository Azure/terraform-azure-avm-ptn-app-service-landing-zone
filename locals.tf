locals {
  # App Service Environment
  app_service_environment_id = var.app_service_environment_resource_id != null ? var.app_service_environment_resource_id : (
    var.app_service_environment_enabled ? module.app_service_environment[0].resource_id : null
  )
  app_service_environment_subnet_id = var.app_service_environment_subnet_resource_id != null ? var.app_service_environment_subnet_resource_id : (
    var.virtual_network_enabled && var.app_service_environment_enabled ? (
      module.virtual_network[0].subnets["app_service_environment"].resource_id
    ) : null
  )
  # App Service Plan ID
  # When a BYO service plan ID is provided from azurerm_service_plan, the ID uses "serverFarms" (camelCase),
  # but Azure API normalizes to "serverfarms" (lowercase). The azapi-based web app module is case-sensitive,
  # causing an infinite plan diff. Normalize the casing to match Azure's convention.
  app_service_plan_id = var.app_service_plan_resource_id != null ? replace(var.app_service_plan_resource_id, "Microsoft.Web/serverFarms", "Microsoft.Web/serverfarms") : (
    var.app_service_plan_enabled ? module.app_service_plan[0].resource_id : null
  )
  # Subnet IDs
  app_service_subnet_id = var.app_service_subnet_resource_id != null ? var.app_service_subnet_resource_id : (
    var.virtual_network_enabled && !var.app_service_environment_enabled ? (
      module.virtual_network[0].subnets["app_service"].resource_id
    ) : null
  )
  # Application Insights - auto-wire connection string to web apps when AI is created by this module
  application_insights_connection_string = var.application_insights_enabled ? module.application_insights[0].connection_string : null
  application_insights_key               = var.application_insights_enabled ? module.application_insights[0].instrumentation_key : null
  # Managed Identity for Managed Instance - used for plan default identity
  managed_instance_managed_identity_resource_id = var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? module.managed_instance_managed_identity[0].resource_id : null
  # Bastion Host
  bastion_host_effectively_enabled = coalesce(var.bastion_host_enabled, var.app_service_plan_os_type == "WindowsManagedInstance")
  bastion_host_subnet_id = var.bastion_host_subnet_resource_id != null ? var.bastion_host_subnet_resource_id : (
    var.virtual_network_enabled && local.bastion_host_effectively_enabled ? (
      module.virtual_network[0].subnets["AzureBastionSubnet"].resource_id
    ) : null
  )
  create_private_dns_zone_key_vault    = var.private_dns_zones_enabled && var.virtual_network_enabled && var.key_vault_enabled
  create_private_dns_zone_storage_blob = var.private_dns_zones_enabled && var.virtual_network_enabled && var.storage_account_enabled
  # Private DNS Zone
  create_private_dns_zone_web = var.private_dns_zones_enabled && var.virtual_network_enabled
  # App Service Plan - auto-adjust SKU for ASE (Isolated tier required)
  effective_sku_name = var.app_service_environment_enabled && !startswith(var.app_service_plan_sku_name, "I") ? "I1v2" : var.app_service_plan_sku_name
  private_dns_zone_web_id = var.private_dns_zone_web_resource_id != null ? var.private_dns_zone_web_resource_id : (
    local.create_private_dns_zone_web ? module.private_dns_zone_web[0].resource_id : null
  )
  private_endpoint_subnet_id = var.private_endpoint_subnet_resource_id != null ? var.private_endpoint_subnet_resource_id : (
    var.virtual_network_enabled ? (
      module.virtual_network[0].subnets["private_endpoints"].resource_id
    ) : null
  )
  resource_group_id = "/subscriptions/${data.azapi_client_config.this.subscription_id}/resourceGroups/${var.resource_group_name}"
  # Virtual networking
  virtual_network_enabled = var.virtual_network_enabled
  virtual_network_id = var.virtual_network_resource_id != null ? var.virtual_network_resource_id : (
    var.virtual_network_enabled ? module.virtual_network[0].resource_id : null
  )
  # Web App OS type - WindowsManagedInstance plans host Windows web apps
  web_app_default_os_type = var.app_service_plan_os_type == "WindowsManagedInstance" ? "Windows" : var.app_service_plan_os_type
}
