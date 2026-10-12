module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.11.0"
  count   = var.key_vault_enabled || local.managed_instance_key_vault_needed ? 1 : 0

  location                       = var.location
  name                           = coalesce(var.key_vault_name, module.naming.resource_names.key_vault)
  resource_group_name            = local.resource_group_name
  tenant_id                      = data.azapi_client_config.this.tenant_id
  diagnostic_settings            = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.key_vault_diagnostic_settings
  enable_telemetry               = var.enable_telemetry
  legacy_access_policies_enabled = !var.key_vault_enable_rbac_authorization
  lock                           = var.key_vault_lock
  network_acls                   = var.key_vault_network_acls
  private_endpoints = local.virtual_network_enabled ? {
    default = {
      subnet_resource_id            = local.private_endpoint_subnet_id
      private_dns_zone_resource_ids = local.private_dns_zone_key_vault_id != null ? toset([local.private_dns_zone_key_vault_id]) : toset([])
    }
  } : {}
  public_network_access_enabled = var.key_vault_public_network_access_enabled
  purge_protection_enabled      = var.key_vault_purge_protection_enabled
  role_assignments = nonsensitive(merge(
    var.key_vault_role_assignments,
    var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? {
      managed_instance_secrets_user = {
        role_definition_id_or_name       = "Key Vault Secrets User"
        principal_id                     = module.managed_instance_managed_identity[0].principal_id
        skip_service_principal_aad_check = true
        principal_type                   = "ServicePrincipal"
      }
    } : {}
  ))
  secrets                    = nonsensitive(merge(var.key_vault_secrets, local.managed_instance_registry_adapter_secrets))
  secrets_value              = var.key_vault_secrets_value != null ? merge(var.key_vault_secrets_value, local.managed_instance_registry_adapter_secrets_value) : (length(local.managed_instance_registry_adapter_secrets_value) > 0 ? local.managed_instance_registry_adapter_secrets_value : null)
  sku_name                   = var.key_vault_sku_name
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days
  tags                       = try(coalesce(var.key_vault_tags, var.tags), {})
}
