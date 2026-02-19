module "private_dns_zone_web" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"
  count   = local.create_private_dns_zone_web ? 1 : 0

  domain_name      = "privatelink.azurewebsites.net"
  parent_id        = local.resource_group_id
  enable_telemetry = var.enable_telemetry
  tags             = var.tags
  virtual_network_links = {
    vnet_link = {
      name               = "vnetlink-${var.name}"
      virtual_network_id = local.virtual_network_id
    }
  }
}
