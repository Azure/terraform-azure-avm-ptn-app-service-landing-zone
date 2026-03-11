variable "managed_instance_managed_identity_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether to create a User-Assigned Managed Identity for the App Service Plan default identity when using WindowsManagedInstance mode. This identity is used by the platform for install scripts, registry adapters, and storage mounts. Has no effect when `app_service_plan_os_type` is not `WindowsManagedInstance`. Defaults to true."
  nullable    = false
}

variable "managed_instance_managed_identity_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the User-Assigned Managed Identity for the App Service Managed Instance plan default identity. If not set, defaults to 'id-{name}'. Only applies when `app_service_plan_os_type` is `WindowsManagedInstance`."
}
