variable "location" {
  type        = string
  description = "Azure region where the resources should be deployed."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The resource ID of the resource group where the resources will be deployed. The resource group must already exist."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id))
    error_message = "The parent_id must be a valid Azure resource group resource ID (e.g., /subscriptions/{sub}/resourceGroups/{rg})."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "default_diagnostic_settings_enabled" {
  type        = bool
  default     = true
  description = "(Optional) When true and no custom diagnostic settings are provided, default diagnostic settings will be created that send logs and metrics to the Log Analytics workspace. A workspace is created by default when `log_analytics_workspace_enabled = true`, or you can supply an existing one via `log_analytics_workspace_resource_id`. Set to `false` to disable default diagnostic settings."
  nullable    = false

  validation {
    condition     = !var.default_diagnostic_settings_enabled || var.log_analytics_workspace_enabled || var.log_analytics_workspace_resource_id != null
    error_message = "Either `log_analytics_workspace_enabled` must be `true` or `log_analytics_workspace_resource_id` must be set when `default_diagnostic_settings_enabled` is `true`."
  }
}

variable "log_analytics_workspace_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing Log Analytics workspace (BYO). When set, the module will use this workspace instead of creating one. When set along with `default_diagnostic_settings_enabled = true`, diagnostic settings on created resources will be configured to send logs and metrics to this workspace."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to apply to all resources created by this module."
}
