module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.7"
  count   = var.storage_account_enabled || local.managed_instance_storage_account_needed ? 1 : 0

  location                            = var.location
  name                                = coalesce(var.storage_account_name, module.naming.resource_names.storage_account)
  resource_group_name                 = local.resource_group_name
  access_tier                         = var.storage_account_access_tier
  account_replication_type            = var.storage_account_account_replication_type
  account_tier                        = var.storage_account_account_tier
  containers                          = merge(var.storage_account_containers, local.managed_instance_containers)
  diagnostic_settings_blob            = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.storage_account_diagnostic_settings_blob
  diagnostic_settings_file            = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.storage_account_diagnostic_settings_file
  diagnostic_settings_queue           = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.storage_account_diagnostic_settings_queue
  diagnostic_settings_storage_account = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.storage_account_diagnostic_settings
  diagnostic_settings_table           = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.storage_account_diagnostic_settings_table
  enable_telemetry                    = var.enable_telemetry
  network_rules                       = var.storage_account_network_rules
  private_endpoints = local.virtual_network_enabled ? merge(
    {
      blob = {
        subresource_name              = "blob"
        subnet_resource_id            = local.private_endpoint_subnet_id
        private_dns_zone_resource_ids = local.private_dns_zone_storage_blob_id != null ? toset([local.private_dns_zone_storage_blob_id]) : toset([])
      }
    },
    length(merge(var.storage_account_shares, local.managed_instance_shares)) > 0 ? {
      file = {
        subresource_name              = "file"
        subnet_resource_id            = local.private_endpoint_subnet_id
        private_dns_zone_resource_ids = local.private_dns_zone_storage_file_id != null ? toset([local.private_dns_zone_storage_file_id]) : toset([])
      }
    } : {}
  ) : {}
  public_network_access_enabled = var.storage_account_public_network_access_enabled
  role_assignments = merge(
    var.storage_account_role_assignments,
    var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? {
      managed_instance_blob_reader = {
        role_definition_id_or_name       = "Storage Blob Data Reader"
        principal_id                     = module.managed_instance_managed_identity[0].principal_id
        skip_service_principal_aad_check = true
        principal_type                   = "ServicePrincipal"
      }
    } : {}
  )
  shared_access_key_enabled = var.storage_account_shared_access_key_enabled || local.managed_instance_shared_access_key_needed
  shares                    = merge(var.storage_account_shares, local.managed_instance_shares)
  tags                      = try(coalesce(var.storage_account_tags, var.tags), {})
}

# Upload blobs for managed instance install scripts.
# NOTE: azurerm_storage_blob is used because blob upload is a data plane
# operation not supported by azapi or any AVM module.
resource "azurerm_storage_blob" "managed_instance" {
  for_each = local.managed_instance_blobs

  name                   = each.value.name
  storage_account_name   = module.storage_account[0].name
  storage_container_name = each.value.container_name
  type                   = each.value.type
  source                 = each.value.source
}

# Store the storage account connection string in Key Vault for AzureFiles storage mounts.
# This secret is created outside the AVM module because its value depends on the
# storage account key, which is only available after the storage account is created.
resource "azapi_resource" "managed_instance_storage_connection_string" {
  count = local.managed_instance_shared_access_key_needed ? 1 : 0

  name      = "mi-storage-connection-string"
  parent_id = module.key_vault[0].resource_id
  type      = "Microsoft.KeyVault/vaults/secrets@2023-07-01"
  body = {
    properties = {
      value = "DefaultEndpointsProtocol=https;AccountName=${module.storage_account[0].name};AccountKey=${data.azapi_resource_action.managed_instance_storage_account_keys[0].output.keys[0].value};EndpointSuffix=core.windows.net"
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.storage_account_retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Retrieve the storage account keys when AzureFiles mounts are configured.
data "azapi_resource_action" "managed_instance_storage_account_keys" {
  count = local.managed_instance_shared_access_key_needed ? 1 : 0

  action                 = "listKeys"
  resource_id            = module.storage_account[0].resource_id
  type                   = "Microsoft.Storage/storageAccounts@2023-05-01"
  response_export_values = ["keys"]
}
