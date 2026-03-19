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
  # Bastion Host
  bastion_host_effectively_enabled = var.bastion_host_enabled
  bastion_host_subnet_id = var.bastion_host_subnet_resource_id != null ? var.bastion_host_subnet_resource_id : (
    var.virtual_network_enabled && local.bastion_host_effectively_enabled ? (
      module.virtual_network[0].subnets["AzureBastionSubnet"].resource_id
    ) : null
  )
  # Private DNS Zones
  create_private_dns_zone_key_vault    = var.private_dns_zone_key_vault_resource_id == null && var.private_dns_zones_enabled && var.virtual_network_enabled && (var.key_vault_enabled || local.managed_instance_key_vault_needed) && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  create_private_dns_zone_storage_blob = var.private_dns_zone_storage_blob_resource_id == null && var.private_dns_zones_enabled && var.virtual_network_enabled && (var.storage_account_enabled || local.managed_instance_storage_account_needed) && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  create_private_dns_zone_storage_file = var.private_dns_zone_storage_file_resource_id == null && var.private_dns_zones_enabled && var.virtual_network_enabled && (var.storage_account_enabled || local.managed_instance_storage_account_needed) && length(merge(var.storage_account_shares, local.managed_instance_shares)) > 0 && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  create_private_dns_zone_web          = var.private_dns_zones_enabled && var.virtual_network_enabled && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  # App Service Plan - auto-adjust SKU for ASE (Isolated tier required)
  effective_sku_name = var.app_service_environment_enabled && !startswith(var.app_service_plan_sku_name, "I") ? "I1v2" : var.app_service_plan_sku_name
  private_dns_zone_container_registry_id = var.private_dns_zone_container_registry_resource_id != null ? var.private_dns_zone_container_registry_resource_id : (
    local.create_private_dns_zone_container_registry ? module.private_dns_zone_container_registry[0].resource_id : null
  )
  private_dns_zone_key_vault_id = var.private_dns_zone_key_vault_resource_id != null ? var.private_dns_zone_key_vault_resource_id : (
    local.create_private_dns_zone_key_vault ? module.private_dns_zone_key_vault[0].resource_id : null
  )
  private_dns_zone_storage_blob_id = var.private_dns_zone_storage_blob_resource_id != null ? var.private_dns_zone_storage_blob_resource_id : (
    local.create_private_dns_zone_storage_blob ? module.private_dns_zone_storage_blob[0].resource_id : null
  )
  private_dns_zone_storage_file_id = var.private_dns_zone_storage_file_resource_id != null ? var.private_dns_zone_storage_file_resource_id : (
    local.create_private_dns_zone_storage_file ? module.private_dns_zone_storage_file[0].resource_id : null
  )
  private_dns_zone_web_id = var.private_dns_zone_web_resource_id != null ? var.private_dns_zone_web_resource_id : (
    local.create_private_dns_zone_web ? module.private_dns_zone_web[0].resource_id : null
  )
  private_endpoint_subnet_id = var.private_endpoint_subnet_resource_id != null ? var.private_endpoint_subnet_resource_id : (
    var.virtual_network_enabled ? (
      module.virtual_network[0].subnets["private_endpoints"].resource_id
    ) : null
  )
  resource_group_id   = var.parent_id
  resource_group_name = provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id).resource_group_name
  # Storage Account
  storage_account_id = var.storage_account_enabled || local.managed_instance_storage_account_needed ? module.storage_account[0].resource_id : var.storage_account_resource_id
  # Virtual networking
  virtual_network_enabled = var.virtual_network_enabled
  virtual_network_id = var.virtual_network_resource_id != null ? var.virtual_network_resource_id : (
    var.virtual_network_enabled ? module.virtual_network[0].resource_id : null
  )
  # Web App OS type - WindowsManagedInstance and WindowsContainer plans host Windows web apps
  web_app_default_os_type = contains(["WindowsManagedInstance", "WindowsContainer"], var.app_service_plan_os_type) ? "Windows" : var.app_service_plan_os_type
}
