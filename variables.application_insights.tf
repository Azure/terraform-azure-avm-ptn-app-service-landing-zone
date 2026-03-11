variable "application_insights_application_type" {
  type        = string
  default     = "web"
  description = "(Optional) The type of Application Insights to create. Possible values are 'web', 'ios', 'java', 'phone', 'MobileCenter', 'other', 'store'. Defaults to 'web'."
}

variable "application_insights_daily_data_cap_in_gb" {
  type        = number
  default     = 100
  description = "(Optional) The daily data volume cap in GB. Defaults to 100."
}

variable "application_insights_daily_data_cap_notifications_disabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether to disable notifications when the daily data cap is reached. Defaults to false."
}

variable "application_insights_disable_ip_masking" {
  type        = bool
  default     = false
  description = "(Optional) Whether to disable IP masking. Defaults to false (IPs are masked for privacy)."
}

variable "application_insights_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether to create an Application Insights resource. Defaults to true."
  nullable    = false
}

variable "application_insights_force_customer_storage_for_profiler" {
  type        = bool
  default     = false
  description = "(Optional) Whether to force customer storage for profiler. Defaults to false."
}

variable "application_insights_internet_ingestion_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether internet ingestion is enabled. Defaults to true."
  nullable    = false
}

variable "application_insights_internet_query_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether internet query is enabled. Defaults to true."
  nullable    = false
}

variable "application_insights_linked_storage_account" {
  type = map(object({
    resource_id = optional(string, null)
  }))
  default     = {}
  description = "(Optional) Linked storage account configuration for the Application Insights profiler."
  nullable    = false
}

variable "application_insights_local_authentication_disabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether to disable non-AAD based authentication. Defaults to false."
}

variable "application_insights_lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = "(Optional) Controls the resource lock configuration for the Application Insights resource."
}

variable "application_insights_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Application Insights resource. If not set, defaults to 'ai-{name}'."
}

variable "application_insights_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing Application Insights resource. When set, the module will not create an Application Insights resource."
}

variable "application_insights_retention_in_days" {
  type        = number
  default     = 90
  description = "(Optional) The retention period in days. Defaults to 90."
}

variable "application_insights_role_assignments" {
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
  description = "(Optional) A map of role assignments to create on the Application Insights resource."
  nullable    = false
}

variable "application_insights_sampling_percentage" {
  type        = number
  default     = 100
  description = "(Optional) The sampling percentage (1-100). 100 means all data is collected. Defaults to 100."
}

variable "application_insights_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to apply to the Application Insights resource. If null, the module-level tags are used."
}
