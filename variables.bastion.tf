variable "bastion_host_copy_paste_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Specifies whether copy-paste functionality is enabled for the Azure Bastion Host. Defaults to true."
}

variable "bastion_host_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Whether to create an Azure Bastion Host. When null (default), bastion is automatically enabled for WindowsManagedInstance plans and disabled otherwise. Set explicitly to true or false to override this behavior."
}

variable "bastion_host_file_copy_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether file copy functionality is enabled for the Azure Bastion Host. Requires Standard or Premium SKU. Defaults to false."
}

variable "bastion_host_ip_connect_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether IP connect functionality is enabled for the Azure Bastion Host. Requires Standard or Premium SKU. Defaults to false."
}

variable "bastion_host_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Azure Bastion Host. Defaults to 'bas-{name}'."
}

variable "bastion_host_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing Azure Bastion Host. When set, the module will not create a Bastion Host."
}

variable "bastion_host_scale_units" {
  type        = number
  default     = 2
  description = "(Optional) The number of scale units for the Azure Bastion Host. Defaults to 2."
}

variable "bastion_host_sku" {
  type        = string
  default     = "Standard"
  description = "(Optional) The SKU of the Azure Bastion Host. Possible values are 'Basic', 'Standard', 'Developer', or 'Premium'. Defaults to 'Standard'."
  nullable    = false

  validation {
    condition     = contains(["Basic", "Standard", "Developer", "Premium"], var.bastion_host_sku)
    error_message = "The bastion_host_sku must be one of: 'Basic', 'Standard', 'Developer', 'Premium'."
  }
}

variable "bastion_host_subnet_address_prefix" {
  type        = string
  default     = "10.0.3.0/26"
  description = "The address prefix for the AzureBastionSubnet. Must be at least /26. Only used when creating a new virtual network and bastion is enabled."
}

variable "bastion_host_subnet_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing AzureBastionSubnet. When set, the module will not create the bastion subnet."
}

variable "bastion_host_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to apply to the Azure Bastion Host. If null, the module-level tags are used."
}

variable "bastion_host_tunneling_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether tunneling functionality (native client support) is enabled for the Azure Bastion Host. Requires Standard or Premium SKU. Defaults to false."
}

variable "bastion_host_zones" {
  type        = set(string)
  default     = ["1", "2", "3"]
  description = "(Optional) The availability zones where the Azure Bastion Host is deployed. Defaults to all three zones."
}
