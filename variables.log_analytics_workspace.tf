variable "log_analytics_workspace_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether to create a Log Analytics workspace. Set to `false` when providing `log_analytics_workspace_resource_id` to use an existing workspace. Defaults to `true`."
  nullable    = false
}

variable "log_analytics_workspace_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Log Analytics workspace. If not provided, a name will be generated using the naming module."
}
