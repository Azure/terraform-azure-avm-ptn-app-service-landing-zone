variable "app_service_plan_diagnostic_settings" {
  type = map(object({
    name = optional(string, null)
    logs = optional(set(object({
      category       = optional(string, null)
      category_group = optional(string, null)
      enabled        = optional(bool, true)
      retention_policy = optional(object({
        days    = optional(number, 0)
        enabled = optional(bool, false)
      }), {})
    })), [])
    metrics = optional(set(object({
      category = optional(string, null)
      enabled  = optional(bool, true)
      retention_policy = optional(object({
        days    = optional(number, 0)
        enabled = optional(bool, false)
      }), {})
    })), [])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = "(Optional) A map of diagnostic settings to create on the App Service Plan."
  nullable    = false
}

variable "app_service_plan_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether to create an App Service Plan. Set to false when providing app_service_plan_resource_id. Defaults to true."
  nullable    = false
}

variable "app_service_plan_install_scripts" {
  type = list(object({
    name = string
    source = object({
      type       = optional(string, "RemoteAzureBlob")
      source_uri = string
    })
  }))
  default     = null
  description = "(Optional) A list of install scripts to run on the Managed Instance App Service Plan. Only applicable when os_type is WindowsManagedInstance."
}

variable "app_service_plan_lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Controls the Resource Lock configuration for the App Service Plan.

- `kind` - (Required) The type of lock. Possible values are `CanNotDelete` and `ReadOnly`.
- `name` - (Optional) The name of the lock.
DESCRIPTION
}

variable "app_service_plan_managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Controls the Managed Identity configuration on the App Service Plan.

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled. Defaults to false.
- `user_assigned_resource_ids` - (Optional) Specifies a set of User Assigned Managed Identity resource IDs.
DESCRIPTION
  nullable    = false
}

variable "app_service_plan_maximum_elastic_worker_count" {
  type        = number
  default     = 3
  description = "(Optional) The maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan."
}

variable "app_service_plan_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the App Service Plan. Defaults to 'asp-{name}'."
}

variable "app_service_plan_os_type" {
  type        = string
  default     = "Linux"
  description = "The OS type for the App Service Plan. Possible values are 'Linux', 'Windows', 'WindowsContainer', or 'WindowsManagedInstance'. Defaults to 'Linux'."
  nullable    = false

  validation {
    condition     = contains(["Linux", "Windows", "WindowsContainer", "WindowsManagedInstance"], var.app_service_plan_os_type)
    error_message = "The OS type must be one of: 'Linux', 'Windows', 'WindowsContainer', 'WindowsManagedInstance'."
  }
}

variable "app_service_plan_per_site_scaling_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Should per site scaling be enabled for this App Service Plan. Defaults to false."
  nullable    = false
}

variable "app_service_plan_plan_default_identity" {
  type = object({
    identity_type                      = optional(string, "UserAssigned")
    user_assigned_identity_resource_id = string
  })
  default     = null
  description = <<DESCRIPTION
(Optional) The default identity configuration for the Managed Instance App Service Plan. Only applicable when os_type is WindowsManagedInstance.

- `identity_type` - (Optional) The type of the identity. Defaults to "UserAssigned".
- `user_assigned_identity_resource_id` - (Required) The resource ID of the user-assigned managed identity.
DESCRIPTION
}

variable "app_service_plan_premium_plan_auto_scale_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Should elastic scale be enabled for this App Service Plan. Only set to true if deploying a Premium or Elastic Premium SKU. Defaults to false."
  nullable    = false
}

variable "app_service_plan_rdp_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether RDP is enabled for the Managed Instance App Service Plan. Only applicable when os_type is WindowsManagedInstance. Defaults to false."
  nullable    = false
}

variable "app_service_plan_registry_adapters" {
  type = list(object({
    registry_key = string
    type         = string
    key_vault_secret_reference = object({
      secret_uri = string
    })
  }))
  default     = null
  description = <<DESCRIPTION
(Optional) A list of registry adapters associated with this App Service Plan. Only applicable when os_type is WindowsManagedInstance.

- `registry_key` - (Required) Registry key for the adapter.
- `type` - (Required) Type of the registry adapter. Possible values are "DWORD" or "String".
- `key_vault_secret_reference` - (Required) Key vault reference to the value.
  - `secret_uri` - (Required) The URI of the Key Vault secret.
DESCRIPTION
}

variable "app_service_plan_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing App Service Plan. When set, the module will not create an App Service Plan."
}

variable "app_service_plan_retry" {
  type = object({
    error_message_regex  = optional(list(string), ["ScopeLocked", "AnotherOperationInProgress"])
    interval_seconds     = optional(number, null)
    max_interval_seconds = optional(number, null)
  })
  default     = null
  description = "(Optional) Retry configuration for transient errors on the App Service Plan."
}

variable "app_service_plan_role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = "(Optional) A map of role assignments to create on the App Service Plan."
  nullable    = false
}

variable "app_service_plan_sku_name" {
  type        = string
  default     = "P1v3"
  description = "The SKU name for the App Service Plan. Defaults to 'P1v3' (Premium v3, 2 vCPUs, 8 GB RAM). Use Isolated SKUs ('I1v2', 'I2v2', 'I3v2', etc.) when deploying with an App Service Environment. The SKU is automatically adjusted to 'I1v2' when `app_service_environment_enabled` is true and a non-Isolated SKU is specified."
  nullable    = false

  validation {
    condition     = can(regex("^(B1|B2|B3|D1|F1|I1|I2|I3|I1v2|I2v2|I3v2|I4v2|I5v2|I6v2|P1v2|P2v2|P3v2|P0v3|P1v3|P2v3|P3v3|P1mv3|P2mv3|P3mv3|P4mv3|P5mv3|P0v4|P1v4|P2v4|P3v4|P1mv4|P2mv4|P3mv4|P4mv4|P5mv4|S1|S2|S3|SHARED|EP1|EP2|EP3|FC1|WS1|WS2|WS3|Y1)$", var.app_service_plan_sku_name))
    error_message = "Invalid App Service Plan SKU. Must be a valid SKU such as P1v3, P2v3, P1v2, I1v2, S1, B1, EP1, etc."
  }
}

variable "app_service_plan_storage_mounts" {
  type = list(object({
    name             = string
    type             = optional(string, "LocalStorage")
    source           = optional(string, "")
    destination_path = string
    credentials_key_vault_reference = optional(object({
      secret_uri = optional(string)
    }), {})
  }))
  default     = null
  description = "(Optional) A list of storage mounts to configure on the App Service Plan. Only applicable when os_type is WindowsManagedInstance."
}

variable "app_service_plan_timeouts" {
  type = object({
    create = optional(string, null)
    delete = optional(string, null)
    read   = optional(string, null)
    update = optional(string, null)
  })
  default     = null
  description = "(Optional) Timeouts for App Service Plan resource operations."
}

variable "app_service_plan_virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of the subnet to integrate the App Service Plan with. This enables VNet integration for the plan."
}

variable "app_service_plan_worker_count" {
  type        = number
  default     = 3
  description = "The number of workers (instances) for the App Service Plan. Defaults to 3 for zone redundancy support."
  nullable    = false
}

variable "app_service_plan_zone_balancing_enabled" {
  type        = bool
  default     = true
  description = "Whether zone balancing (zone redundancy) is enabled for the App Service Plan. Defaults to true."
  nullable    = false
}
