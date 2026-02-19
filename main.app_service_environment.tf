module "app_service_environment" {
  source  = "Azure/avm-res-web-hostingenvironment/azurerm"
  version = "2.0.0"
  count   = var.app_service_environment_enabled && var.app_service_environment_resource_id == null ? 1 : 0

  location                     = var.location
  name                         = coalesce(var.app_service_environment_name, "ase-${var.name}")
  parent_id                    = local.resource_group_id
  subnet_id                    = local.app_service_environment_subnet_id
  enable_telemetry             = var.enable_telemetry
  internal_encryption_enabled  = true
  internal_load_balancing_mode = var.app_service_environment_internal_load_balancing_mode
  tags                         = var.tags
  zone_redundancy_enabled      = var.app_service_environment_zone_redundancy_enabled
}
