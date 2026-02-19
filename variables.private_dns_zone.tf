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
