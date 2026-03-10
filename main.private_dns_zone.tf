module "private_dns_zone_web" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"
  count   = local.create_private_dns_zone_web ? 1 : 0

  domain_name = "privatelink.azurewebsites.net"
  parent_id   = local.resource_group_id
  # DNS records
  a_records        = var.private_dns_zone_a_records
  aaaa_records     = var.private_dns_zone_aaaa_records
  cname_records    = var.private_dns_zone_cname_records
  enable_telemetry = var.enable_telemetry
  # Management
  lock                                 = var.private_dns_zone_lock
  mx_records                           = var.private_dns_zone_mx_records
  ptr_records                          = var.private_dns_zone_ptr_records
  retry                                = var.private_dns_zone_retry
  role_assignment_name_use_random_uuid = var.private_dns_zone_role_assignment_name_use_random_uuid
  role_assignments                     = var.private_dns_zone_role_assignments
  soa_record                           = var.private_dns_zone_soa_record
  srv_records                          = var.private_dns_zone_srv_records
  tags                                 = var.tags
  timeouts                             = var.private_dns_zone_timeouts
  txt_records                          = var.private_dns_zone_txt_records
  virtual_network_links = merge(
    {
      vnet_link = {
        name               = "vnetlink-${var.name}"
        virtual_network_id = local.virtual_network_id
      }
    },
    var.private_dns_zone_additional_virtual_network_links
  )
}

module "private_dns_zone_key_vault" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"
  count   = local.create_private_dns_zone_key_vault ? 1 : 0

  domain_name      = "privatelink.vaultcore.azure.net"
  parent_id        = local.resource_group_id
  enable_telemetry = var.enable_telemetry
  tags             = var.tags
  virtual_network_links = {
    vnet_link = {
      name               = "vnetlink-kv-${var.name}"
      virtual_network_id = local.virtual_network_id
    }
  }
}

module "private_dns_zone_storage_blob" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"
  count   = local.create_private_dns_zone_storage_blob ? 1 : 0

  domain_name      = "privatelink.blob.core.windows.net"
  parent_id        = local.resource_group_id
  enable_telemetry = var.enable_telemetry
  tags             = var.tags
  virtual_network_links = {
    vnet_link = {
      name               = "vnetlink-blob-${var.name}"
      virtual_network_id = local.virtual_network_id
    }
  }
}
