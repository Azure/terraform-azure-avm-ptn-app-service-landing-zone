variable "key_vault_diagnostic_settings" {
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
  description = "(Optional) Diagnostic settings for the Key Vault."
  nullable    = false
}

variable "key_vault_enable_rbac_authorization" {
  type        = bool
  default     = true
  description = "(Optional) Whether to enable RBAC authorization for the Key Vault. Defaults to true."
}

variable "key_vault_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether to create an Azure Key Vault. Defaults to false."
  nullable    = false
}

variable "key_vault_lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = "(Optional) Controls the resource lock configuration for the Key Vault."
}

variable "key_vault_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Key Vault. Must be globally unique, 3-24 characters."
}

variable "key_vault_network_acls" {
  type = object({
    bypass                     = optional(string, "None")
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default     = {}
  description = "(Optional) Network ACL configuration for the Key Vault. Defaults to denying all public access."
  nullable    = false
}

variable "key_vault_public_network_access_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether public network access is enabled for the Key Vault. Defaults to false."
}

variable "key_vault_purge_protection_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Specifies whether protection against purge is enabled for this Key Vault. Defaults to true."
}

variable "key_vault_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing Key Vault. When set, the module will not create a Key Vault."
}

variable "key_vault_role_assignments" {
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
  description = "(Optional) A map of role assignments to create on the Key Vault."
  nullable    = false
}

variable "key_vault_secrets" {
  type = map(object({
    name            = string
    content_type    = optional(string, null)
    tags            = optional(map(any), null)
    not_before_date = optional(string, null)
    expiration_date = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
  }))
  default     = {}
  description = "(Optional) A map of secrets to create in the Key Vault."
  nullable    = false
}

variable "key_vault_secrets_value" {
  type        = map(string)
  default     = null
  description = "(Optional) A map of secret keys to their values. The map key must match the key used in `key_vault_secrets`."
  sensitive   = true
}

variable "key_vault_sku_name" {
  type        = string
  default     = "premium"
  description = "(Optional) The SKU name of the Key Vault. Possible values are 'standard' and 'premium'. Defaults to 'premium'."
}

variable "key_vault_soft_delete_retention_days" {
  type        = number
  default     = 90
  description = "(Optional) The number of days to retain soft-deleted keys, secrets, and certificates. Defaults to 90."
}

variable "key_vault_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to apply to the Key Vault. If null, the module-level tags are used."
}
