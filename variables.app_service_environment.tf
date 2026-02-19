variable "app_service_environment_allow_new_private_endpoint_connections" {
  type        = bool
  default     = true
  description = "(Optional) Enable new private endpoint connection creation on the App Service Environment (ASE). Defaults to true."
}

variable "app_service_environment_cluster_settings" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = <<DESCRIPTION
(Optional) Custom settings for changing the behavior of the App Service Environment (ASE).

- `name` - (Required) The name of the cluster setting.
- `value` - (Required) The value of the cluster setting.
DESCRIPTION
  nullable    = false
}

variable "app_service_environment_custom_dns_suffix_configuration" {
  type = object({
    certificate_url              = string
    dns_suffix                   = string
    key_vault_reference_identity = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Custom domain suffix configuration for the App Service Environment (ASE).

- `certificate_url` - (Required) The URL referencing the Azure Key Vault certificate secret.
- `dns_suffix` - (Required) The default custom domain suffix to use for all sites deployed on the ASE.
- `key_vault_reference_identity` - (Optional) The user-assigned identity to use for resolving the key vault certificate reference.
DESCRIPTION
}

variable "app_service_environment_dedicated_host_count" {
  type        = number
  default     = null
  description = "(Optional) Dedicated Host Count for the App Service Environment (ASE). Possible value is 2."

  validation {
    condition     = var.app_service_environment_dedicated_host_count == null || var.app_service_environment_dedicated_host_count == 2
    error_message = "The number of dedicated hosts must be null or 2."
  }
}

variable "app_service_environment_diagnostic_settings" {
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
  description = "(Optional) A map of diagnostic settings to create on the App Service Environment (ASE)."
  nullable    = false
}

variable "app_service_environment_enabled" {
  type        = bool
  default     = false
  description = "Whether to deploy an App Service Environment (ASE v3). Defaults to false, using an App Service Plan instead for a more cost-effective deployment. When enabled, the App Service Plan SKU is automatically set to Isolated tier if not already."
  nullable    = false
}

variable "app_service_environment_fips_mode_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable FIPS mode on the App Service Environment (ASE). Defaults to false."
}

variable "app_service_environment_front_end_tls_cipher_suite_order" {
  type        = string
  default     = null
  description = "(Optional) The TLS cipher suite order to use on the App Service Environment (ASE)."
}

variable "app_service_environment_ftp_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable FTP on the App Service Environment (ASE). Defaults to false."
}

variable "app_service_environment_inbound_ip_address_override" {
  type        = string
  default     = null
  description = "(Optional) Customer provided Inbound IP Address. Only able to be set on ASE create."
}

variable "app_service_environment_internal_encryption_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Enable internal encryption on the App Service Environment (ASE). Defaults to true."
}

variable "app_service_environment_internal_load_balancing_mode" {
  type        = string
  default     = "Web, Publishing"
  description = "The internal load balancing mode for the ASE. Possible values are 'None', 'Web', 'Publishing', 'Web, Publishing'. Defaults to 'Web, Publishing' for internal-only access."
}

variable "app_service_environment_lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Controls the Resource Lock configuration for the App Service Environment.

- `kind` - (Required) The type of lock. Possible values are `CanNotDelete` and `ReadOnly`.
- `name` - (Optional) The name of the lock.
DESCRIPTION
}

variable "app_service_environment_managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Controls the Managed Identity configuration on the App Service Environment.

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled. Defaults to false.
- `user_assigned_resource_ids` - (Optional) Specifies a set of User Assigned Managed Identity resource IDs.
DESCRIPTION
  nullable    = false
}

variable "app_service_environment_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the App Service Environment. Defaults to 'ase-{name}'."
}

variable "app_service_environment_remote_debug_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Enable Remote Debug on the App Service Environment (ASE)."
}

variable "app_service_environment_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing App Service Environment. When set, the module will not create an ASE."
}

variable "app_service_environment_retry" {
  type = object({
    error_message_regex  = optional(list(string), ["ScopeLocked"])
    interval_seconds     = optional(number, null)
    max_interval_seconds = optional(number, null)
  })
  default     = null
  description = "(Optional) Retry configuration for transient errors on the App Service Environment."
}

variable "app_service_environment_role_assignments" {
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
  description = "(Optional) A map of role assignments to create on the App Service Environment."
  nullable    = false
}

variable "app_service_environment_timeouts" {
  type = object({
    create = optional(string, "6h")
    delete = optional(string, "6h")
    read   = optional(string, "5m")
    update = optional(string, "6h")
  })
  default     = null
  description = "(Optional) Timeouts for App Service Environment resource operations. ASE operations can take a long time (defaults: 6h for create/delete/update)."
}

variable "app_service_environment_tls_1_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable TLS 1.0 on the App Service Environment (ASE). Defaults to false."
}

variable "app_service_environment_upgrade_preference" {
  type        = string
  default     = "None"
  description = "(Optional) Upgrade Preference. Possible values are 'None', 'Early', 'Late', or 'Manual'. Defaults to 'None'."

  validation {
    condition     = contains(["None", "Early", "Late", "Manual"], var.app_service_environment_upgrade_preference)
    error_message = "Possible values are 'None', 'Early', 'Late', or 'Manual'."
  }
}

variable "app_service_environment_zone_redundancy_enabled" {
  type        = bool
  default     = true
  description = "Whether zone redundancy is enabled for the App Service Environment."
  nullable    = false
}
