module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.2"
  count   = var.key_vault_enabled ? 1 : 0

  location                       = var.location
  name                           = var.key_vault_name
  resource_group_name            = var.resource_group_name
  tenant_id                      = data.azapi_client_config.this.tenant_id
  diagnostic_settings            = var.key_vault_diagnostic_settings
  enable_telemetry               = var.enable_telemetry
  legacy_access_policies_enabled = !var.key_vault_enable_rbac_authorization
  lock                           = var.key_vault_lock
  network_acls                   = var.key_vault_network_acls
  private_endpoints = local.virtual_network_enabled ? {
    default = {
      subnet_resource_id            = local.private_endpoint_subnet_id
      private_dns_zone_resource_ids = local.create_private_dns_zone_key_vault ? toset([module.private_dns_zone_key_vault[0].resource_id]) : toset([])
    }
  } : {}
  public_network_access_enabled = var.key_vault_public_network_access_enabled
  purge_protection_enabled      = var.key_vault_purge_protection_enabled
  role_assignments              = var.key_vault_role_assignments
  secrets                       = var.key_vault_secrets
  secrets_value                 = var.key_vault_secrets_value
  sku_name                      = var.key_vault_sku_name
  soft_delete_retention_days    = var.key_vault_soft_delete_retention_days
  tags                          = try(coalesce(var.key_vault_tags, var.tags), {})
}
