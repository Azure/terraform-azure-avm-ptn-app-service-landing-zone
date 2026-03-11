module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.7"
  count   = var.storage_account_enabled ? 1 : 0

  location                            = var.location
  name                                = coalesce(var.storage_account_name, module.naming.resource_names.storage_account)
  resource_group_name                 = local.resource_group_name
  access_tier                         = var.storage_account_access_tier
  account_replication_type            = var.storage_account_account_replication_type
  account_tier                        = var.storage_account_account_tier
  containers                          = var.storage_account_containers
  diagnostic_settings_blob            = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.storage_account_diagnostic_settings_blob
  diagnostic_settings_file            = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.storage_account_diagnostic_settings_file
  diagnostic_settings_queue           = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.storage_account_diagnostic_settings_queue
  diagnostic_settings_storage_account = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.storage_account_diagnostic_settings
  diagnostic_settings_table           = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.storage_account_diagnostic_settings_table
  enable_telemetry                    = var.enable_telemetry
  network_rules                       = var.storage_account_network_rules
  private_endpoints = local.virtual_network_enabled ? {
    blob = {
      subresource_name              = "blob"
      subnet_resource_id            = local.private_endpoint_subnet_id
      private_dns_zone_resource_ids = local.create_private_dns_zone_storage_blob ? toset([module.private_dns_zone_storage_blob[0].resource_id]) : toset([])
    }
  } : {}
  role_assignments          = var.storage_account_role_assignments
  shared_access_key_enabled = var.storage_account_shared_access_key_enabled
  shares                    = var.storage_account_shares
  tags                      = try(coalesce(var.storage_account_tags, var.tags), {})
}
