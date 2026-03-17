locals {
  # --- Blobs derived from install scripts ---
  managed_instance_blobs = {
    for idx, script in var.managed_instance_install_scripts :
    "mi_install_${idx}" => {
      name           = "${script.name}.zip"
      container_name = "install-scripts-${idx}"
      type           = "Block"
      source         = script.source
    }
  }
  # --- Containers derived from install scripts ---
  managed_instance_containers = {
    for idx, script in var.managed_instance_install_scripts :
    "mi_install_${idx}" => {
      name          = "install-scripts-${idx}"
      public_access = "None"
    }
  }
  # --- Install scripts config for the ASP ---
  managed_instance_install_scripts_config = [
    for idx, script in var.managed_instance_install_scripts : {
      name = script.name
      source = {
        type       = "RemoteAzureBlob"
        source_uri = "https://${local.managed_instance_storage_account_name}.blob.core.windows.net/install-scripts-${idx}/${script.name}.zip"
      }
    }
  ]
  # Key vault name - computed once, used when building URIs at plan time
  managed_instance_key_vault_name = coalesce(var.key_vault_name, module.naming.resource_names.key_vault)
  # Auto-enable key vault when convenience variables need it
  managed_instance_key_vault_needed = length(var.managed_instance_registry_adapters) > 0 || length([
    for m in var.managed_instance_storage_mounts : m if m.type == "AzureFiles"
  ]) > 0
  # --- Key vault secrets for registry adapters ---
  managed_instance_registry_adapter_secrets = {
    for idx, adapter in var.managed_instance_registry_adapters :
    "mi_registry_${idx}" => {
      name = "mi-registry-adapter-${idx}"
    }
  }
  managed_instance_registry_adapter_secrets_value = {
    for idx, adapter in var.managed_instance_registry_adapters :
    "mi_registry_${idx}" => adapter.value
  }
  # --- Registry adapters config for the ASP ---
  managed_instance_registry_adapters_config = [
    for idx, adapter in var.managed_instance_registry_adapters : {
      registry_key = adapter.registry_key
      type         = adapter.type
      key_vault_secret_reference = {
        secret_uri = "https://${local.managed_instance_key_vault_name}.vault.azure.net/secrets/mi-registry-adapter-${idx}"
      }
    }
  ]
  # Whether any AzureFiles mounts require shared access keys
  managed_instance_shared_access_key_needed = length([
    for m in var.managed_instance_storage_mounts : m if m.type == "AzureFiles"
  ]) > 0
  # --- Shares derived from AzureFiles storage mounts ---
  managed_instance_shares = {
    for mount in var.managed_instance_storage_mounts :
    "mi_share_${mount.share_name}" => {
      name  = mount.share_name
      quota = mount.share_quota
    }
    if mount.type == "AzureFiles" && mount.share_name != null
  }
  # Storage account name - derived from the storage_account_id local
  managed_instance_storage_account_name = local.storage_account_id != null ? provider::azapi::parse_resource_id("Microsoft.Storage/storageAccounts", local.storage_account_id).resource_name : null
  # Auto-enable storage account when convenience variables need it
  managed_instance_storage_account_needed = length(var.managed_instance_install_scripts) > 0 || length([
    for m in var.managed_instance_storage_mounts : m if m.type == "AzureFiles"
  ]) > 0
  # --- Storage mounts config for the ASP ---
  managed_instance_storage_mounts_config = [
    for mount in var.managed_instance_storage_mounts : mount.type == "AzureFiles" ? {
      name             = mount.name
      type             = "AzureFiles"
      source           = "\\\\${local.managed_instance_storage_account_name}.file.core.windows.net\\${mount.share_name}"
      destination_path = mount.destination_path
      credentials_key_vault_reference = {
        # NOTE: the double slash after the vault URI is intentional to comply with Key Vault secret URI format for this resource
        secret_uri = "https://${local.managed_instance_key_vault_name}.vault.azure.net//secrets/mi-storage-connection-string"
      }
      } : {
      name             = mount.name
      type             = "LocalStorage"
      source           = ""
      destination_path = mount.destination_path
      credentials_key_vault_reference = {
        secret_uri = null
      }
    }
  ]
}
