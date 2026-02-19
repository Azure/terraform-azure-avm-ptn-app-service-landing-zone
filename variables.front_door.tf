variable "front_door_enabled" {
  type        = bool
  default     = true
  description = "Whether to create an Azure Front Door profile for ingress to the web apps. Defaults to true."
  nullable    = false
}

variable "front_door_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Azure Front Door profile. Defaults to 'afd-{name}'."
}

variable "front_door_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing Azure Front Door profile. When set, the module will not create a Front Door profile."
}

variable "front_door_sku" {
  type        = string
  default     = "Premium_AzureFrontDoor"
  description = "The SKU of the Azure Front Door profile. 'Premium_AzureFrontDoor' supports WAF managed rules and private link to origins. 'Standard_AzureFrontDoor' is more cost-effective but does not support private link origins."
  nullable    = false

  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.front_door_sku)
    error_message = "The Front Door SKU must be one of: 'Standard_AzureFrontDoor', 'Premium_AzureFrontDoor'."
  }
}

variable "front_door_waf_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable a Web Application Firewall (WAF) policy on the Azure Front Door with Microsoft managed rule sets. Defaults to true."
  nullable    = false
}
