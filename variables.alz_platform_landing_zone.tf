variable "alz_platform_landing_zone_diagnostic_settings_mode_enabled" {
  type        = bool
  default     = false
  description = "(Optional) When enabled, the module will not configure diagnostic settings on any resources. Instead, it relies on Azure Landing Zone (ALZ) policy (DINE) to create diagnostic settings. Defaults to false."
  nullable    = false
}

variable "alz_platform_landing_zone_peer_from_hub_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the reverse VNet peering from the hub to the spoke. Defaults to 'peer-from-alz-hub-{name}'."
}

variable "alz_platform_landing_zone_peer_to_hub_enabled" {
  type        = bool
  default     = false
  description = "(Optional) When enabled, creates a bi-directional VNet peering to the hub virtual network specified by `alz_platform_landing_zone_peering_hub_virtual_network_id`. Requires `virtual_network_enabled` to be true. Defaults to false."
  nullable    = false
}

variable "alz_platform_landing_zone_peer_to_hub_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the VNet peering from the spoke to the hub. Defaults to 'peer-to-alz-hub'."
}

variable "alz_platform_landing_zone_peering_hub_virtual_network_id" {
  type        = string
  default     = null
  description = "(Required when `alz_platform_landing_zone_peer_to_hub_enabled` is true) The resource ID of the hub virtual network to create a bi-directional peering with."
}

variable "alz_platform_landing_zone_private_dns_zone_mode_enabled" {
  type        = bool
  default     = false
  description = "(Optional) When enabled, the module will not deploy private DNS zones. Instead, it relies on Azure Landing Zone (ALZ) policy to attach private endpoints to the central DNS zone. Defaults to false."
  nullable    = false
}

variable "alz_platform_landing_zone_route_table_address_spaces" {
  type        = list(string)
  default     = []
  description = "(Optional) A list of address spaces (CIDR prefixes) to route through the hub virtual appliance. A route is created for each address space with the virtual appliance as the next hop. Requires `alz_platform_landing_zone_route_table_hub_virtual_appliance_ip_address` to be set."
  nullable    = false
}

variable "alz_platform_landing_zone_route_table_enabled" {
  type        = bool
  default     = false
  description = "(Optional) When enabled, creates a route table for routing traffic through the hub virtual appliance. A default route (0.0.0.0/0) for outbound internet access and routes for specified address spaces are created when `alz_platform_landing_zone_route_table_hub_virtual_appliance_ip_address` is provided. Ignored when `alz_platform_landing_zone_route_table_resource_id` is set. Defaults to false."
  nullable    = false
}

variable "alz_platform_landing_zone_route_table_hub_virtual_appliance_ip_address" {
  type        = string
  default     = null
  description = "(Optional) The private IP address of the hub virtual appliance (e.g., Azure Firewall or NVA). When provided, a default route (0.0.0.0/0) is created pointing to this IP as the next hop."
}

variable "alz_platform_landing_zone_route_table_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the ALZ route table. Defaults to 'rt-alz-{name}'."
}

variable "alz_platform_landing_zone_route_table_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing route table to use. When set, the module will not create a route table and will use this one instead. Takes precedence over `alz_platform_landing_zone_route_table_enabled`."
}
