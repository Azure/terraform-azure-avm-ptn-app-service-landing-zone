variable "storage_account_access_tier" {
  type        = string
  default     = "Hot"
  description = "(Optional) Defines the access tier for the storage account. Valid options are Hot, Cool, Cold, and Premium. Defaults to Hot."
}

variable "storage_account_account_replication_type" {
  type        = string
  default     = "ZRS"
  description = "(Optional) Defines the type of replication to use for the storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS, and RAGZRS. Defaults to ZRS."
}

variable "storage_account_account_tier" {
  type        = string
  default     = "Standard"
  description = "(Optional) Defines the tier to use for this storage account. Valid options are Standard and Premium. Defaults to Standard."
}

variable "storage_account_containers" {
  type = map(object({
    public_access = optional(string, "None")
    metadata      = optional(map(string))
    name          = string
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      principal_type                         = optional(string, null)
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    })), {})
  }))
  default     = {}
  description = "(Optional) A map of blob containers to create in the storage account."
  nullable    = false
}

variable "storage_account_diagnostic_settings" {
  type = map(object({
    name = optional(string, null)
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
  description = "(Optional) Diagnostic settings for the Storage Account resource itself. Note: only metric categories are supported at the storage account level (logs are not supported)."
  nullable    = false
}

variable "storage_account_diagnostic_settings_blob" {
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
  description = "(Optional) Diagnostic settings for the Blob Storage service."
  nullable    = false
}

variable "storage_account_diagnostic_settings_file" {
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
  description = "(Optional) Diagnostic settings for the Azure Files service."
  nullable    = false
}

variable "storage_account_diagnostic_settings_queue" {
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
  description = "(Optional) Diagnostic settings for the Queue Storage service."
  nullable    = false
}

variable "storage_account_diagnostic_settings_table" {
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
  description = "(Optional) Diagnostic settings for the Table Storage service."
  nullable    = false
}

variable "storage_account_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether to create a storage account. Defaults to false."
  nullable    = false
}

variable "storage_account_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the storage account. Must be globally unique, 3-24 characters, lowercase letters and numbers only."
}

variable "storage_account_network_rules" {
  type = object({
    bypass                     = optional(set(string), ["AzureServices"])
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(set(string), [])
    virtual_network_subnet_ids = optional(set(string), [])
  })
  default     = {}
  description = "(Optional) Network rules for the storage account. Defaults to denying all public access with AzureServices bypass."
  nullable    = false
}

variable "storage_account_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing storage account. When set, the module will not create a storage account."
}

variable "storage_account_role_assignments" {
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
  description = "(Optional) A map of role assignments to create on the storage account."
  nullable    = false
}

variable "storage_account_shared_access_key_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Indicates whether the storage account permits requests to be authorized with the account access key. Defaults to false (Azure AD only)."
}

variable "storage_account_shares" {
  type = map(object({
    access_tier      = optional(string)
    enabled_protocol = optional(string)
    metadata         = optional(map(string))
    name             = string
    quota            = number
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      principal_type                         = optional(string, null)
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    })), {})
  }))
  default     = {}
  description = "(Optional) A map of file shares to create in the storage account."
  nullable    = false
}

variable "storage_account_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to apply to the storage account. If null, the module-level tags are used."
}
