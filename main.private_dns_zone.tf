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
        name               = module.naming.resource_names.vnet_link_web
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
  retry            = var.private_dns_zone_retry
  tags             = var.tags
  virtual_network_links = {
    vnet_link = {
      name               = module.naming.resource_names.vnet_link_key_vault
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
  retry            = var.private_dns_zone_retry
  tags             = var.tags
  virtual_network_links = {
    vnet_link = {
      name               = module.naming.resource_names.vnet_link_storage_blob
      virtual_network_id = local.virtual_network_id
    }
  }
}

module "private_dns_zone_storage_file" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"
  count   = local.create_private_dns_zone_storage_file ? 1 : 0

  domain_name      = "privatelink.file.core.windows.net"
  parent_id        = local.resource_group_id
  enable_telemetry = var.enable_telemetry
  retry            = var.private_dns_zone_retry
  tags             = var.tags
  virtual_network_links = {
    vnet_link = {
      name               = module.naming.resource_names.vnet_link_storage_file
      virtual_network_id = local.virtual_network_id
    }
  }
}

module "private_dns_zone_container_registry" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"
  count   = local.create_private_dns_zone_container_registry ? 1 : 0

  domain_name      = "privatelink.azurecr.io"
  parent_id        = local.resource_group_id
  enable_telemetry = var.enable_telemetry
  retry            = var.private_dns_zone_retry
  tags             = var.tags
  virtual_network_links = {
    vnet_link = {
      name               = module.naming.resource_names.vnet_link_container_registry
      virtual_network_id = local.virtual_network_id
    }
  }
}

# ============================================================
# AMPLS Private DNS Zones (for Log Analytics + Application Insights)
# ============================================================

module "private_dns_zone_monitor" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"
  count   = local.create_private_dns_zone_monitor ? 1 : 0

  domain_name      = "privatelink.monitor.azure.com"
  parent_id        = local.resource_group_id
  enable_telemetry = var.enable_telemetry
  retry            = var.private_dns_zone_retry
  tags             = var.tags
  virtual_network_links = {
    vnet_link = {
      name               = module.naming.resource_names.vnet_link_monitor
      virtual_network_id = local.virtual_network_id
    }
  }
}

module "private_dns_zone_oms" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"
  count   = local.create_private_dns_zone_oms ? 1 : 0

  domain_name      = "privatelink.oms.opinsights.azure.com"
  parent_id        = local.resource_group_id
  enable_telemetry = var.enable_telemetry
  retry            = var.private_dns_zone_retry
  tags             = var.tags
  virtual_network_links = {
    vnet_link = {
      name               = module.naming.resource_names.vnet_link_oms
      virtual_network_id = local.virtual_network_id
    }
  }
}

module "private_dns_zone_ods" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"
  count   = local.create_private_dns_zone_ods ? 1 : 0

  domain_name      = "privatelink.ods.opinsights.azure.com"
  parent_id        = local.resource_group_id
  enable_telemetry = var.enable_telemetry
  retry            = var.private_dns_zone_retry
  tags             = var.tags
  virtual_network_links = {
    vnet_link = {
      name               = module.naming.resource_names.vnet_link_ods
      virtual_network_id = local.virtual_network_id
    }
  }
}

module "private_dns_zone_agentsvc" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"
  count   = local.create_private_dns_zone_agentsvc ? 1 : 0

  domain_name      = "privatelink.agentsvc.azure-automation.net"
  parent_id        = local.resource_group_id
  enable_telemetry = var.enable_telemetry
  retry            = var.private_dns_zone_retry
  tags             = var.tags
  virtual_network_links = {
    vnet_link = {
      name               = module.naming.resource_names.vnet_link_agentsvc
      virtual_network_id = local.virtual_network_id
    }
  }
}
