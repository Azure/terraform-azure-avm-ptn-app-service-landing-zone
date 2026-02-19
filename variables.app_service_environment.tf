variable "app_service_environment_enabled" {
  type        = bool
  default     = false
  description = "Whether to deploy an App Service Environment (ASE v3). Defaults to false, using an App Service Plan instead for a more cost-effective deployment. When enabled, the App Service Plan SKU is automatically set to Isolated tier if not already."
  nullable    = false
}

variable "app_service_environment_internal_load_balancing_mode" {
  type        = string
  default     = "Web, Publishing"
  description = "The internal load balancing mode for the ASE. Possible values are 'None', 'Web', 'Publishing', 'Web, Publishing'. Defaults to 'Web, Publishing' for internal-only access."
}

variable "app_service_environment_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the App Service Environment. Defaults to 'ase-{name}'."
}

variable "app_service_environment_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing App Service Environment. When set, the module will not create an ASE."
}

variable "app_service_environment_zone_redundancy_enabled" {
  type        = bool
  default     = true
  description = "Whether zone redundancy is enabled for the App Service Environment."
  nullable    = false
}
