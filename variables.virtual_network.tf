variable "app_service_environment_subnet_address_prefix" {
  type        = string
  default     = "10.0.2.0/24"
  description = "The address prefix for the App Service Environment subnet. Only used when `app_service_environment_enabled` is true and creating a new virtual network."
}

variable "app_service_environment_subnet_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing subnet for the App Service Environment. When set, the module will not create this subnet. The subnet must be delegated to Microsoft.Web/hostingEnvironments."
}

variable "app_service_subnet_address_prefix" {
  type        = string
  default     = "10.0.0.0/24"
  description = "The address prefix for the App Service VNet integration subnet. Only used when creating a new virtual network and `app_service_environment_enabled` is false."
}

variable "app_service_subnet_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing subnet for App Service VNet integration. When set, the module will not create this subnet. The subnet must be delegated to Microsoft.Web/serverFarms."
}

variable "private_endpoint_subnet_address_prefix" {
  type        = string
  default     = "10.0.1.0/24"
  description = "The address prefix for the private endpoint subnet. Only used when creating a new virtual network."
}

variable "private_endpoint_subnet_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing subnet for private endpoints. When set, the module will not create this subnet."
}

variable "virtual_network_address_space" {
  type        = set(string)
  default     = ["10.0.0.0/16"]
  description = "The address space for the virtual network. Only used when creating a new virtual network."
}

variable "virtual_network_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable private networking for the App Service Landing Zone. When true, a virtual network is created (or an existing one is used via `virtual_network_resource_id`) with subnets for App Service integration and private endpoints."
  nullable    = false
}

variable "virtual_network_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the virtual network to create. Defaults to 'vnet-{name}'."
}

variable "virtual_network_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing virtual network to use. When set, the module will not create a virtual network. You must also provide subnet resource IDs via `app_service_subnet_resource_id` and `private_endpoint_subnet_resource_id`."
}
