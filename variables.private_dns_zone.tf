variable "private_dns_zone_a_records" {
  type = map(object({
    name         = string
    ttl          = number
    records      = optional(list(string))
    ip_addresses = optional(set(string), null)
  }))
  default     = {}
  description = "(Optional) A map of A records to create in the private DNS zone."
  nullable    = false
}

variable "private_dns_zone_aaaa_records" {
  type = map(object({
    name         = string
    ttl          = number
    records      = optional(list(string))
    ip_addresses = optional(set(string), null)
  }))
  default     = {}
  description = "(Optional) A map of AAAA records to create in the private DNS zone."
  nullable    = false
}

variable "private_dns_zone_additional_virtual_network_links" {
  type = map(object({
    vnetlinkname                           = optional(string, null)
    name                                   = optional(string, null)
    vnetid                                 = optional(string, null)
    virtual_network_id                     = optional(string, null)
    autoregistration                       = optional(bool, false)
    registration_enabled                   = optional(bool, null)
    private_dns_zone_supports_private_link = optional(bool, false)
    resolution_policy                      = optional(string, "Default")
    tags                                   = optional(map(string), null)
  }))
  default     = {}
  description = "(Optional) A map of additional virtual network links to create in the private DNS zone. These are merged with the auto-generated virtual network link for the deployed virtual network."
  nullable    = false
}

variable "private_dns_zone_cname_records" {
  type = map(object({
    name   = string
    ttl    = number
    record = optional(string, null)
    cname  = optional(string, null)
  }))
  default     = {}
  description = "(Optional) A map of CNAME records to create in the private DNS zone."
  nullable    = false
}

variable "private_dns_zone_container_registry_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing private DNS zone for 'privatelink.azurecr.io'. When set, the module will not create this DNS zone for Container Registry private endpoints."
}

variable "private_dns_zone_key_vault_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing private DNS zone for 'privatelink.vaultcore.azure.net'. When set, the module will not create this DNS zone for Key Vault private endpoints."
}

variable "private_dns_zone_lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Controls the Resource Lock configuration for the private DNS zone. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `"CanNotDelete"` and `"ReadOnly"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value.
DESCRIPTION

  validation {
    condition     = var.private_dns_zone_lock != null ? contains(["CanNotDelete", "ReadOnly"], var.private_dns_zone_lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "private_dns_zone_mx_records" {
  type = map(object({
    name = optional(string, "@")
    ttl  = number
    records = map(object({
      preference = number
      exchange   = string
    }))
  }))
  default     = {}
  description = "(Optional) A map of MX records to create in the private DNS zone."
  nullable    = false
}

variable "private_dns_zone_ptr_records" {
  type = map(object({
    name         = string
    ttl          = number
    records      = optional(list(string), null)
    domain_names = optional(set(string), null)
  }))
  default     = {}
  description = "(Optional) A map of PTR records to create in the private DNS zone."
  nullable    = false
}

variable "private_dns_zone_retry" {
  type = object({
    error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned", "CannotDeleteResource"])
    interval_seconds     = optional(number, 10)
    max_interval_seconds = optional(number, 180)
    multiplier           = optional(number, 1.5)
    randomization_factor = optional(number, 0.5)
  })
  default     = {}
  description = "(Optional) Retry configuration for the private DNS zone resource operations."
}

variable "private_dns_zone_role_assignment_name_use_random_uuid" {
  type        = bool
  default     = true
  description = "(Optional) A control to use a random UUID for role assignment names. If set to false, the name will be a deterministic UUID based on the principal ID and role definition resource ID. Defaults to true."
  nullable    = false
}

variable "private_dns_zone_role_assignments" {
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
  description = "(Optional) A map of role assignments to create on the private DNS zone."
  nullable    = false
}

variable "private_dns_zone_soa_record" {
  type = object({
    email        = string
    name         = optional(string, "@")
    expire_time  = optional(number, 2419200)
    minimum_ttl  = optional(number, 10)
    refresh_time = optional(number, 3600)
    retry_time   = optional(number, 300)
    ttl          = optional(number, 3600)
  })
  default     = null
  description = "(Optional) SOA record configuration for the private DNS zone. If included, only email is required. Email must use username.corp.com format, not username@corp.com."
}

variable "private_dns_zone_srv_records" {
  type = map(object({
    name = string
    ttl  = number
    records = map(object({
      priority = number
      weight   = number
      port     = number
      target   = string
    }))
  }))
  default     = {}
  description = "(Optional) A map of SRV records to create in the private DNS zone."
  nullable    = false
}

variable "private_dns_zone_storage_blob_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing private DNS zone for 'privatelink.blob.core.windows.net'. When set, the module will not create this DNS zone for Storage Account private endpoints."
}

variable "private_dns_zone_storage_file_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing private DNS zone for 'privatelink.file.core.windows.net'. When set, the module will not create this DNS zone for Storage Account file share private endpoints."
}

variable "private_dns_zone_timeouts" {
  type = object({
    dns_zones = optional(object({
      create = optional(string, "30m")
      delete = optional(string, "30m")
      update = optional(string, "30m")
      read   = optional(string, "5m")
    }), {})
    vnet_links = optional(object({
      create = optional(string, "30m")
      delete = optional(string, "30m")
      update = optional(string, "30m")
      read   = optional(string, "5m")
    }), {})
  })
  default     = {}
  description = "(Optional) Timeouts for the private DNS zone and virtual network link resources."
}

variable "private_dns_zone_txt_records" {
  type = map(object({
    name = string
    ttl  = number
    records = map(object({
      value = list(string)
    }))
  }))
  default     = {}
  description = "(Optional) A map of TXT records to create in the private DNS zone."
  nullable    = false
}

variable "private_dns_zone_web_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing private DNS zone for 'privatelink.azurewebsites.net'. When set, the module will not create this DNS zone but will use it for web app private endpoint DNS resolution."
}

variable "private_dns_zones_enabled" {
  type        = bool
  default     = true
  description = "Whether to create private DNS zones for private endpoint resolution. Defaults to true. Only effective when virtual networking is enabled."
  nullable    = false
}
