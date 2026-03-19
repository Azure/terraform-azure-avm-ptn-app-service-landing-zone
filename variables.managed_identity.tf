variable "managed_instance_install_scripts" {
  type = list(object({
    name   = string
    source = string
  }))
  default     = []
  description = <<DESCRIPTION
(Optional) A convenience variable to configure install scripts for the Managed Instance App Service Plan.
The module automatically creates the storage account container, uploads the script zip blob, and configures
the `app_service_plan_install_scripts` input. Only applicable when `app_service_plan_os_type` is `WindowsManagedInstance`.

When set, the module automatically enables the storage account and key vault if not already enabled.

- `name` - (Required) The name of the install script (e.g. "CustomInstaller").
- `source` - (Required) The local file path to the zip file to upload.

For more granular control, use the existing `app_service_plan_install_scripts`, `storage_account_*`, and `key_vault_*` variables instead.
DESCRIPTION
  nullable    = false
}

variable "managed_instance_managed_identity_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether to create a User-Assigned Managed Identity for the App Service Plan default identity when using WindowsManagedInstance mode. This identity is used by the platform for install scripts, registry adapters, and storage mounts. Has no effect when `app_service_plan_os_type` is not `WindowsManagedInstance`. Defaults to true."
  nullable    = false
}

variable "managed_instance_managed_identity_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the User-Assigned Managed Identity for the App Service Managed Instance plan default identity. If not set, defaults to 'id-{name}'. Only applies when `app_service_plan_os_type` is `WindowsManagedInstance`."
}

variable "managed_instance_registry_adapters" {
  type = list(object({
    registry_key = string
    type         = string
    value        = string
  }))
  default     = []
  description = <<DESCRIPTION
(Optional) A convenience variable to configure Windows registry adapters for the Managed Instance App Service Plan.
The module automatically creates Key Vault secrets and configures the `app_service_plan_registry_adapters` input
with Key Vault secret references. Only applicable when `app_service_plan_os_type` is `WindowsManagedInstance`.

When set, the module automatically enables the key vault if not already enabled.

- `registry_key` - (Required) The Windows registry key path (e.g. "HKEY_LOCAL_MACHINE/SOFTWARE/MyApp1/Setting").
- `type` - (Required) The registry value type. Possible values are "String" or "DWORD".
- `value` - (Required) The value to store in the registry key.

For more granular control, use the existing `app_service_plan_registry_adapters` and `key_vault_*` variables instead.
DESCRIPTION
  nullable    = false
  sensitive   = true
}

variable "managed_instance_storage_mounts" {
  type = list(object({
    name             = string
    destination_path = string
    type             = optional(string, "LocalStorage")
    share_name       = optional(string, null)
    share_quota      = optional(number, 5)
  }))
  default     = []
  description = <<DESCRIPTION
(Optional) A convenience variable to configure storage mounts for the Managed Instance App Service Plan.
The module automatically creates Azure Files shares, Key Vault secrets for connection strings, and configures
the `app_service_plan_storage_mounts` input. Only applicable when `app_service_plan_os_type` is `WindowsManagedInstance`.

When set with AzureFiles mounts, the module automatically enables the storage account (with shared access keys)
and key vault if not already enabled, creates the file shares, and stores the storage account connection string
in Key Vault.

- `name` - (Required) The name of the storage mount (e.g. "g-drive").
- `destination_path` - (Required) The drive letter / mount path (e.g. "G:\\").
- `type` - (Optional) The mount type. Possible values are "LocalStorage" or "AzureFiles". Defaults to "LocalStorage".
- `share_name` - (Required for AzureFiles) The name of the Azure Files share to create.
- `share_quota` - (Optional) The quota in GB for the Azure Files share. Defaults to 5. Only used when `type` is "AzureFiles".

For more granular control, use the existing `app_service_plan_storage_mounts`, `storage_account_*`, and `key_vault_*` variables instead.
DESCRIPTION
  nullable    = false
}
