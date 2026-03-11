variable "container_registry_diagnostic_settings" {
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
  description = "(Optional) Diagnostic settings for the Container Registry."
  nullable    = false
}

variable "container_registry_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Whether to create an Azure Container Registry. Defaults to null, which auto-enables when any web app uses a container-based configuration."
}

variable "container_registry_lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = "(Optional) Controls the resource lock configuration for the Container Registry."
}

variable "container_registry_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Container Registry. Must be globally unique, 5-50 characters, alphanumeric only."
}

variable "container_registry_network_rule_set" {
  type = object({
    default_action = optional(string, "Deny")
    ip_rule = optional(list(object({
      action   = optional(string, "Allow")
      ip_range = string
    })), [])
  })
  default     = null
  description = "(Optional) Network rule set configuration for the Container Registry. Requires Premium SKU."
}

variable "container_registry_public_network_access_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether public network access is enabled for the Container Registry. Defaults to true."
}

variable "container_registry_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing Container Registry. When set, the module will not create a Container Registry."
}

variable "container_registry_role_assignments" {
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
  description = "(Optional) A map of role assignments to create on the Container Registry."
  nullable    = false
}

variable "container_registry_sku" {
  type        = string
  default     = "Premium"
  description = "(Optional) The SKU name of the Container Registry. Possible values are 'Basic', 'Standard', and 'Premium'. Defaults to 'Premium'."

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.container_registry_sku)
    error_message = "The SKU must be one of: 'Basic', 'Standard', 'Premium'."
  }
}

variable "container_registry_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to apply to the Container Registry. If null, the module-level tags are used."
}

variable "container_registry_zone_redundancy_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether zone redundancy is enabled for the Container Registry. Requires Premium SKU. Defaults to true."
}
