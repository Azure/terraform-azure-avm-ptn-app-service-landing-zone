module "web_app" {
  source   = "Azure/avm-res-web-site/azurerm"
  version  = "0.21.1"
  for_each = var.web_apps

  # Required
  location                 = var.location
  name                     = each.value.name
  parent_id                = local.resource_group_id
  service_plan_resource_id = local.app_service_plan_id
  # Pass-through from web_apps map
  all_child_resources_inherit_tags       = each.value.all_child_resources_inherit_tags
  always_ready                           = each.value.always_ready
  app_service_active_slot                = each.value.app_service_active_slot
  app_settings                           = each.value.app_settings
  application_insights_connection_string = try(coalesce(each.value.application_insights_connection_string, local.application_insights_connection_string), null)
  application_insights_key               = try(coalesce(each.value.application_insights_key, local.application_insights_key), null)
  auth_settings                          = each.value.auth_settings
  auth_settings_v2                       = each.value.auth_settings_v2
  auto_generated_domain_name_label_scope = each.value.auto_generated_domain_name_label_scope
  backup                                 = each.value.backup
  builtin_logging_enabled                = each.value.builtin_logging_enabled
  bundle_version                         = each.value.bundle_version
  client_affinity_enabled                = each.value.client_affinity_enabled
  client_affinity_partitioning_enabled   = each.value.client_affinity_partitioning_enabled
  client_affinity_proxy_enabled          = each.value.client_affinity_proxy_enabled
  client_certificate_enabled             = each.value.client_certificate_enabled
  client_certificate_exclusion_paths     = each.value.client_certificate_exclusion_paths
  client_certificate_mode                = each.value.client_certificate_mode
  connection_strings                     = each.value.connection_strings
  container_size                         = each.value.container_size
  content_share_force_disabled           = each.value.content_share_force_disabled
  custom_domains                         = each.value.custom_domains
  daily_memory_time_quota                = each.value.daily_memory_time_quota
  dapr_config                            = each.value.dapr_config
  deployment_slots = {
    for slot_key, slot_value in each.value.deployment_slots : slot_key => merge(slot_value,
      # Per-slot managed identities - merge module-created identity with user-supplied ones
      slot_value.managed_identity_enabled ? {
        managed_identities = {
          system_assigned = slot_value.managed_identities.system_assigned
          user_assigned_resource_ids = setunion(
            slot_value.managed_identities.user_assigned_resource_ids,
            [module.web_app_slot_managed_identity["${each.key}-${slot_key}"].resource_id]
          )
        }
      } : {},
      # ASE overrides
      var.app_service_environment_enabled ? {
        vnet_content_share_enabled = true
        vnet_image_pull_enabled    = true
      } : {},
      # VNet image pull for ACR
      local.container_registry_effectively_enabled && local.virtual_network_enabled && !var.app_service_environment_enabled ? {
        vnet_image_pull_enabled = true
      } : {},
      # Container registry managed identity site_config
      local.container_registry_effectively_enabled && (slot_value.managed_identity_enabled || each.value.managed_identity_enabled) ? {
        site_config = merge(slot_value.site_config, {
          container_registry_use_managed_identity       = true
          container_registry_managed_identity_client_id = slot_value.managed_identity_enabled ? module.web_app_slot_managed_identity["${each.key}-${slot_key}"].client_id : module.web_app_managed_identity[each.key].client_id
        })
      } : {}
    )
  }
  deployment_slots_inherit_lock            = each.value.deployment_slots_inherit_lock
  diagnostic_settings                      = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.web_app_diagnostic_settings[each.key]
  dns_configuration                        = each.value.dns_configuration
  enable_telemetry                         = coalesce(each.value.enable_telemetry, var.enable_telemetry)
  enabled                                  = each.value.enabled
  end_to_end_encryption_enabled            = each.value.end_to_end_encryption_enabled
  fc1_runtime_name                         = each.value.fc1_runtime_name
  fc1_runtime_version                      = each.value.fc1_runtime_version
  ftp_publish_basic_authentication_enabled = each.value.ftp_publish_basic_authentication_enabled
  function_app_uses_fc1                    = each.value.function_app_uses_fc1
  functions_extension_version              = each.value.functions_extension_version
  host_names_disabled                      = each.value.host_names_disabled
  hosting_environment_id                   = each.value.hosting_environment_id
  https_only                               = each.value.https_only
  hyper_v                                  = each.value.hyper_v
  instance_memory_in_mb                    = each.value.instance_memory_in_mb
  ip_mode                                  = each.value.ip_mode
  key_vault_reference_identity             = each.value.key_vault_reference_identity
  kind                                     = each.value.kind
  lock                                     = each.value.lock
  logic_app_runtime_version                = each.value.logic_app_runtime_version
  logs                                     = each.value.logs
  managed_environment_id                   = each.value.managed_environment_id
  managed_identities = {
    system_assigned = each.value.managed_identities.system_assigned
    user_assigned_resource_ids = setunion(
      each.value.managed_identities.user_assigned_resource_ids,
      each.value.managed_identity_enabled ? [module.web_app_managed_identity[each.key].resource_id] : []
    )
  }
  maximum_instance_count = each.value.maximum_instance_count
  os_type                = coalesce(each.value.os_type, local.web_app_default_os_type)
  # Computed values with user override support
  private_endpoints = each.value.private_endpoints != null ? each.value.private_endpoints : (
    local.virtual_network_enabled && !var.app_service_environment_enabled ? {
      default = {
        subnet_resource_id                      = local.private_endpoint_subnet_id
        private_dns_zone_resource_ids           = local.private_dns_zone_web_id != null ? toset([local.private_dns_zone_web_id]) : toset([])
        application_security_group_associations = {}
        ip_configurations                       = {}
        location                                = null
        lock                                    = null
        name                                    = null
        network_interface_name                  = null
        private_dns_zone_group_name             = "default"
        private_service_connection_name         = null
        resource_group_name                     = null
        role_assignments                        = {}
        tags                                    = null
      }
    } : {}
  )
  private_endpoints_inherit_lock           = each.value.private_endpoints_inherit_lock
  private_endpoints_manage_dns_zone_group  = each.value.private_endpoints_manage_dns_zone_group
  public_network_access_enabled            = each.value.public_network_access_enabled
  redundancy_mode                          = each.value.redundancy_mode
  resource_config                          = each.value.resource_config
  role_assignments                         = each.value.role_assignments
  scm_publish_basic_authentication_enabled = each.value.scm_publish_basic_authentication_enabled
  scm_site_also_stopped                    = each.value.scm_site_also_stopped
  site_config = local.container_registry_effectively_enabled && each.value.managed_identity_enabled ? merge(each.value.site_config, {
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = module.web_app_managed_identity[each.key].client_id
  }) : each.value.site_config
  slot_sensitive_app_settings                    = try(var.web_app_slot_sensitive_app_settings[each.key], {})
  slots_storage_shares_to_mount_sensitive_values = try(var.web_app_slots_storage_shares_to_mount_sensitive_values[each.key], {})
  ssh_enabled                                    = each.value.ssh_enabled
  sticky_settings                                = each.value.sticky_settings
  storage_account_access_key                     = each.value.storage_account_access_key
  storage_account_name                           = each.value.storage_account_name
  storage_account_required                       = each.value.storage_account_required
  storage_account_share_name                     = each.value.storage_account_share_name
  storage_authentication_type                    = each.value.storage_authentication_type
  storage_container_endpoint                     = each.value.storage_container_endpoint
  storage_container_type                         = each.value.storage_container_type
  storage_shares_to_mount                        = each.value.storage_shares_to_mount
  storage_user_assigned_identity_id              = each.value.storage_user_assigned_identity_id
  storage_uses_managed_identity                  = each.value.storage_uses_managed_identity
  tags                                           = merge(coalesce(var.tags, {}), coalesce(each.value.tags, {}))
  timeouts                                       = each.value.timeouts
  use_extension_bundle                           = each.value.use_extension_bundle
  virtual_network_backup_restore_enabled         = each.value.virtual_network_backup_restore_enabled
  virtual_network_subnet_id                      = each.value.virtual_network_subnet_id != null ? each.value.virtual_network_subnet_id : (var.app_service_environment_enabled || var.app_service_plan_os_type == "WindowsManagedInstance" ? null : local.app_service_subnet_id)
  vnet_application_traffic_enabled               = each.value.vnet_application_traffic_enabled
  vnet_content_share_enabled                     = each.value.vnet_content_share_enabled != null ? each.value.vnet_content_share_enabled : (var.app_service_environment_enabled ? true : false)
  vnet_image_pull_enabled                        = each.value.vnet_image_pull_enabled != null ? each.value.vnet_image_pull_enabled : (var.app_service_environment_enabled || (local.container_registry_effectively_enabled && local.virtual_network_enabled) ? true : false)
  vnet_route_all_traffic                         = each.value.vnet_route_all_traffic
  workload_profile_name                          = each.value.workload_profile_name
  zip_deploy_file                                = each.value.zip_deploy_file
}
