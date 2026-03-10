module "bastion_host" {
  source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "0.9.0"
  count   = local.bastion_host_effectively_enabled && var.bastion_host_resource_id == null ? 1 : 0

  location           = var.location
  name               = coalesce(var.bastion_host_name, "bas-${var.name}")
  parent_id          = local.resource_group_id
  copy_paste_enabled = var.bastion_host_copy_paste_enabled
  enable_telemetry   = var.enable_telemetry
  file_copy_enabled  = var.bastion_host_file_copy_enabled
  ip_configuration = {
    name             = "bastion-ipconfig"
    subnet_id        = local.bastion_host_subnet_id
    create_public_ip = true
  }
  ip_connect_enabled = var.bastion_host_ip_connect_enabled
  scale_units        = var.bastion_host_scale_units
  sku                = var.bastion_host_sku
  tags               = coalesce(var.bastion_host_tags, var.tags)
  tunneling_enabled  = var.bastion_host_tunneling_enabled
  zones              = var.bastion_host_zones
}
