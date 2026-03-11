variable "location" {
  type        = string
  description = "Azure region for the resources."
  nullable    = false
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Controls whether telemetry is enabled for sub-modules."
  nullable    = false
}

variable "resource_name_defaults" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
A map of resource name templates keyed by resource type. Override individual templates to customize naming.
Templates use the templatestring function with these available variables:
- resource_name_workload
- resource_name_environment
- location
- short_location (abbreviated region name from the regions utility module)
- sequence (3-digit padded sequence number, e.g. 001)
- unique_name (4-character random string for globally unique resources)
DESCRIPTION
}

variable "resource_name_environment" {
  type        = string
  default     = "dev"
  description = "The environment name segment used in resource name templates."
  nullable    = false
}

variable "resource_name_sequence_start_number" {
  type        = number
  default     = 1
  description = "The starting sequence number used in resource name templates. Formatted as a 3-character string (e.g. 001)."
  nullable    = false
}

variable "resource_name_workload" {
  type        = string
  default     = "demo"
  description = "The workload name segment used in resource name templates."
  nullable    = false
}

variable "web_app_keys" {
  type        = list(string)
  default     = []
  description = "List of web app map keys, used to compute per-app sequence numbers."
}

variable "web_app_slot_keys" {
  type        = map(list(string))
  default     = {}
  description = "Map of web app key to list of deployment slot keys."
}
