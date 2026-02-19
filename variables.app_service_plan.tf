variable "app_service_plan_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the App Service Plan. Defaults to 'asp-{name}'."
}

variable "app_service_plan_os_type" {
  type        = string
  default     = "Linux"
  description = "The OS type for the App Service Plan. Possible values are 'Linux', 'Windows', or 'WindowsManagedInstance'. Defaults to 'Linux'."
  nullable    = false

  validation {
    condition     = contains(["Linux", "Windows", "WindowsManagedInstance"], var.app_service_plan_os_type)
    error_message = "The OS type must be one of: 'Linux', 'Windows', 'WindowsManagedInstance'."
  }
}

variable "app_service_plan_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing App Service Plan. When set, the module will not create an App Service Plan."
}

variable "app_service_plan_sku_name" {
  type        = string
  default     = "P1v3"
  description = "The SKU name for the App Service Plan. Defaults to 'P1v3' (Premium v3, 2 vCPUs, 8 GB RAM). Use Isolated SKUs ('I1v2', 'I2v2', 'I3v2', etc.) when deploying with an App Service Environment. The SKU is automatically adjusted to 'I1v2' when `app_service_environment_enabled` is true and a non-Isolated SKU is specified."
  nullable    = false

  validation {
    condition     = can(regex("^(B1|B2|B3|D1|F1|I1|I2|I3|I1v2|I2v2|I3v2|I4v2|I5v2|I6v2|P1v2|P2v2|P3v2|P0v3|P1v3|P2v3|P3v3|P1mv3|P2mv3|P3mv3|P4mv3|P5mv3|P0v4|P1v4|P2v4|P3v4|P1mv4|P2mv4|P3mv4|P4mv4|P5mv4|S1|S2|S3|SHARED|EP1|EP2|EP3|FC1|WS1|WS2|WS3|Y1)$", var.app_service_plan_sku_name))
    error_message = "Invalid App Service Plan SKU. Must be a valid SKU such as P1v3, P2v3, P1v2, I1v2, S1, B1, EP1, etc."
  }
}

variable "app_service_plan_worker_count" {
  type        = number
  default     = 3
  description = "The number of workers (instances) for the App Service Plan. Defaults to 3 for zone redundancy support."
  nullable    = false
}

variable "app_service_plan_zone_balancing_enabled" {
  type        = bool
  default     = true
  description = "Whether zone balancing (zone redundancy) is enabled for the App Service Plan. Defaults to true."
  nullable    = false
}
