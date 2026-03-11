variable "app_service_environment_subnet_address_prefix" {
  type        = string
  default     = "10.0.2.0/24"
  description = "The address prefix for the App Service Environment subnet. Only used when `app_service_environment_enabled` is true and creating a new virtual network."
}

variable "app_service_environment_subnet_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing subnet for the App Service Environment. When set, the module will not create this subnet. The subnet must be delegated to Microsoft.Web/hostingEnvironments."
}

variable "app_service_subnet_address_prefix" {
  type        = string
  default     = "10.0.0.0/24"
  description = "The address prefix for the App Service VNet integration subnet. Only used when creating a new virtual network and `app_service_environment_enabled` is false."
}

variable "app_service_subnet_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing subnet for App Service VNet integration. When set, the module will not create this subnet. The subnet must be delegated to Microsoft.Web/serverFarms."
}

variable "private_endpoint_subnet_address_prefix" {
  type        = string
  default     = "10.0.1.0/24"
  description = "The address prefix for the private endpoint subnet. Only used when creating a new virtual network."
}

variable "private_endpoint_subnet_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing subnet for private endpoints. When set, the module will not create this subnet."
}

variable "virtual_network_address_space" {
  type        = set(string)
  default     = ["10.0.0.0/16"]
  description = "The address space for the virtual network. Only used when creating a new virtual network."
}

variable "virtual_network_bgp_community" {
  type        = string
  default     = null
  description = "(Optional) The BGP community to send to the virtual network gateway."
}

variable "virtual_network_ddos_protection_plan" {
  type = object({
    id     = string
    enable = bool
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Specifies an Azure Network DDoS Protection Plan.

- `id` - (Required) The ID of the DDoS Protection Plan.
- `enable` - (Required) Enables or disables the DDoS Protection Plan on the Virtual Network.
DESCRIPTION
}

variable "virtual_network_diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = "(Optional) A map of diagnostic settings to create on the virtual network."
  nullable    = false
}

variable "virtual_network_dns_servers" {
  type = object({
    dns_servers = list(string)
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Specifies a list of IP addresses representing DNS servers.

- `dns_servers` - List of IP addresses of DNS servers.
DESCRIPTION
}

variable "virtual_network_enable_vm_protection" {
  type        = bool
  default     = false
  description = "(Optional) Enable VM Protection for the virtual network. Defaults to false."
}

variable "virtual_network_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable private networking for the App Service Landing Zone. When true, a virtual network is created (or an existing one is used via `virtual_network_resource_id`) with subnets for App Service integration and private endpoints."
  nullable    = false
}

variable "virtual_network_encryption" {
  type = object({
    enabled     = bool
    enforcement = string
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Specifies the encryption settings for the virtual network.

- `enabled` - Specifies whether encryption is enabled for the virtual network.
- `enforcement` - Specifies the enforcement mode. Possible values are `AllowUnencrypted` and `DropUnencrypted`.
DESCRIPTION
}

variable "virtual_network_extended_location" {
  type = object({
    name = string
    type = string
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Specifies the extended location of the virtual network.

- `name` - The name of the extended location.
- `type` - The type of the extended location.
DESCRIPTION
}

variable "virtual_network_flow_timeout_in_minutes" {
  type        = number
  default     = null
  description = "(Optional) The flow timeout in minutes for the virtual network."
}

variable "virtual_network_ipam_pools" {
  type = list(object({
    id            = string
    prefix_length = number
  }))
  default     = null
  description = <<DESCRIPTION
(Optional) Specifies the IPAM settings for requesting an address_space from an IP Pool.

- `id` - The ID of the IPAM pool.
- `prefix_length` - The length of the CIDR range to request.
DESCRIPTION
}

variable "virtual_network_lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Controls the Resource Lock configuration for the virtual network.

- `kind` - (Required) The type of lock. Possible values are `CanNotDelete` and `ReadOnly`.
- `name` - (Optional) The name of the lock.
DESCRIPTION
}

variable "virtual_network_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the virtual network to create. Defaults to 'vnet-{name}'."
}

variable "virtual_network_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing virtual network to use. When set, the module will not create a virtual network. You must also provide subnet resource IDs via `app_service_subnet_resource_id` and `private_endpoint_subnet_resource_id`."
}

variable "virtual_network_retry" {
  type = object({
    error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned"])
    interval_seconds     = optional(number, 10)
    max_interval_seconds = optional(number, 180)
  })
  default     = null
  description = "(Optional) Retry configuration for the virtual network resource operations."
}

variable "virtual_network_role_assignments" {
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
  description = "(Optional) A map of role assignments to create on the virtual network."
  nullable    = false
}

variable "virtual_network_timeouts" {
  type = object({
    create = optional(string, "30m")
    read   = optional(string, "5m")
    update = optional(string, "30m")
    delete = optional(string, "30m")
  })
  default     = {}
  description = "(Optional) Timeouts for the virtual network resource operations."
}
