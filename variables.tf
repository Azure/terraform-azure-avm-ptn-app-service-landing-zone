variable "location" {
  type        = string
  description = "Azure region where the resources should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The base name used for naming resources in this module. Individual resource names can be overridden using their respective name variables (e.g., `virtual_network_name`, `app_service_plan_name`)."
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,50}$", var.name))
    error_message = "The name must be between 1 and 50 characters long and can only contain letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the resources will be deployed. The resource group must already exist."
  nullable    = false
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

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to apply to all resources created by this module."
}
