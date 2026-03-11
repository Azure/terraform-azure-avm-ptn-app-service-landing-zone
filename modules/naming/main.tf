module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.11.0"

  enable_telemetry = var.enable_telemetry
  use_cached_data  = true
}

resource "random_string" "unique_name" {
  length  = 4
  special = false
  upper   = false
}

locals {
  alz_peer_from_hub_name       = templatestring(local.templates["alz_peer_from_hub"], local.single_template_vars)
  alz_peer_to_hub_name         = templatestring(local.templates["alz_peer_to_hub"], local.single_template_vars)
  alz_route_table_name         = templatestring(local.templates["alz_route_table"], local.single_template_vars)
  app_service_environment_name = templatestring(local.templates["app_service_environment"], local.single_template_vars)
  app_service_plan_name        = templatestring(local.templates["app_service_plan"], local.single_template_vars)
  application_gateway_backend_pool_names = {
    for key in local.sorted_web_app_keys : key => templatestring(local.templates["application_gateway_backend_pool"], local.web_app_template_vars[key])
  }
  application_gateway_http_setting_names = {
    for key in local.sorted_web_app_keys : key => templatestring(local.templates["application_gateway_http_setting"], local.web_app_template_vars[key])
  }
  application_gateway_listener_names = {
    for key in local.sorted_web_app_keys : key => templatestring(local.templates["application_gateway_listener"], local.web_app_template_vars[key])
  }
  application_gateway_name = templatestring(local.templates["application_gateway"], local.single_template_vars)
  application_gateway_probe_names = {
    for key in local.sorted_web_app_keys : key => templatestring(local.templates["application_gateway_probe"], local.web_app_template_vars[key])
  }
  application_gateway_public_ip_name = templatestring(local.templates["application_gateway_public_ip"], local.single_template_vars)
  application_gateway_routing_rule_names = {
    for key in local.sorted_web_app_keys : key => templatestring(local.templates["application_gateway_routing_rule"], local.web_app_template_vars[key])
  }
  application_insights_name = templatestring(local.templates["application_insights"], local.single_template_vars)
  bastion_host_name         = templatestring(local.templates["bastion_host"], local.single_template_vars)
  container_registry_name   = templatestring(local.templates["container_registry"], local.single_template_vars)
  front_door_endpoint_names = {
    for key in local.sorted_web_app_keys : key => templatestring(local.templates["front_door_endpoint"], local.web_app_template_vars[key])
  }
  front_door_name = templatestring(local.templates["front_door"], local.single_template_vars)
  front_door_origin_group_names = {
    for key in local.sorted_web_app_keys : key => templatestring(local.templates["front_door_origin_group"], local.web_app_template_vars[key])
  }
  front_door_origin_names = {
    for key in local.sorted_web_app_keys : key => templatestring(local.templates["front_door_origin"], local.web_app_template_vars[key])
  }
  front_door_route_names = {
    for key in local.sorted_web_app_keys : key => templatestring(local.templates["front_door_route"], local.web_app_template_vars[key])
  }
  front_door_security_policy_name = templatestring(local.templates["front_door_security_policy"], local.single_template_vars)
  front_door_waf_policy_name      = templatestring(local.templates["front_door_waf_policy"], local.single_template_vars)
  key_vault_name                  = templatestring(local.templates["key_vault"], local.single_template_vars)
  managed_identity_name           = templatestring(local.templates["managed_identity"], local.single_template_vars)
  peer_from_hub_name              = templatestring(local.templates["peer_from_hub"], local.single_template_vars)
  peer_to_hub_name                = templatestring(local.templates["peer_to_hub"], local.single_template_vars)
  # Short location from the regions module, preferring geo_code over short_name
  short_location = try(
    coalesce(
      module.regions.regions_by_name[var.location].geo_code,
      module.regions.regions_by_name[var.location].short_name
    ),
    var.location
  )
  # Common template variables for single-instance resources
  single_template_vars = {
    resource_name_workload    = var.resource_name_workload
    resource_name_environment = var.resource_name_environment
    location                  = var.location
    short_location            = local.short_location
    sequence                  = format("%03d", var.resource_name_sequence_start_number)
    unique_name               = random_string.unique_name.result
  }
  # Per-slot template variables
  slot_items = flatten([
    for app_key in local.sorted_web_app_keys : [
      for slot_idx, slot_key in sort(try(var.web_app_slot_keys[app_key], [])) : {
        key      = "${app_key}-${slot_key}"
        app_key  = app_key
        slot_key = slot_key
        vars = {
          resource_name_workload    = var.resource_name_workload
          resource_name_environment = var.resource_name_environment
          location                  = var.location
          short_location            = local.short_location
          sequence                  = format("%03d", var.resource_name_sequence_start_number + slot_idx)
          unique_name               = random_string.unique_name.result
        }
      }
    ]
  ])
  # Sorted web app keys for consistent sequence numbering
  sorted_web_app_keys  = sort(var.web_app_keys)
  storage_account_name = templatestring(local.templates["storage_account"], local.single_template_vars)
  # Use templates directly from variable
  templates = var.resource_name_defaults
  # ============================================================
  # Computed resource names - single instance
  # ============================================================
  virtual_network_name              = templatestring(local.templates["virtual_network"], local.single_template_vars)
  vnet_link_container_registry_name = templatestring(local.templates["vnet_link_container_registry"], local.single_template_vars)
  vnet_link_key_vault_name          = templatestring(local.templates["vnet_link_key_vault"], local.single_template_vars)
  vnet_link_storage_blob_name       = templatestring(local.templates["vnet_link_storage_blob"], local.single_template_vars)
  vnet_link_web_name                = templatestring(local.templates["vnet_link_web"], local.single_template_vars)
  web_app_managed_identity_names = {
    for key in local.sorted_web_app_keys : key => templatestring(local.templates["web_app_managed_identity"], local.web_app_template_vars[key])
  }
  # ============================================================
  # Computed resource names - per web app
  # ============================================================
  web_app_names = {
    for key in local.sorted_web_app_keys : key => templatestring(local.templates["web_app"], local.web_app_template_vars[key])
  }
  # ============================================================
  # Computed resource names - per slot
  # ============================================================
  web_app_slot_managed_identity_names = {
    for item in local.slot_items : item.key => templatestring(local.templates["web_app_slot_managed_identity"], item.vars)
  }
  # Per-web-app template variables (with per-app sequence numbers)
  web_app_template_vars = {
    for idx, key in local.sorted_web_app_keys : key => {
      resource_name_workload    = var.resource_name_workload
      resource_name_environment = var.resource_name_environment
      location                  = var.location
      short_location            = local.short_location
      sequence                  = format("%03d", var.resource_name_sequence_start_number + idx)
      unique_name               = random_string.unique_name.result
    }
  }
}
