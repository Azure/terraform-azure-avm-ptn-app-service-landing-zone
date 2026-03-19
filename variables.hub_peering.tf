variable "hub_peering_enabled" {
  type        = bool
  default     = false
  description = "Whether to create a VNet peering to a hub virtual network. Requires `virtual_network_enabled` to be true or a virtual network to be created by this module."
  nullable    = false
}

variable "hub_virtual_network_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of the hub virtual network to peer with. Required when `hub_peering_enabled` is true."
}
