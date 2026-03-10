variable "egress_lockdown_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether to create a route table for egress lockdown through a firewall. Defaults to false."
  nullable    = false
}

variable "firewall_private_ip" {
  type        = string
  default     = null
  description = "(Optional) The private IP address of the Azure Firewall in the hub network. Required when egress_lockdown_enabled is true. A default route (0.0.0.0/0) will be created pointing to this IP."
}

variable "route_table_bgp_route_propagation_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether BGP route propagation is enabled on the route table. Defaults to false (propagation disabled)."
}

variable "route_table_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the route table. If not set, defaults to 'rt-{name}'."
}
