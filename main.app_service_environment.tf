module "app_service_environment" {
  source  = "Azure/avm-res-web-hostingenvironment/azurerm"
  version = "2.0.0"
  count   = var.app_service_environment_enabled && var.app_service_environment_resource_id == null ? 1 : 0

  location                               = var.location
  name                                   = coalesce(var.app_service_environment_name, "ase-${var.name}")
  parent_id                              = local.resource_group_id
  subnet_id                              = local.app_service_environment_subnet_id
  allow_new_private_endpoint_connections = var.app_service_environment_allow_new_private_endpoint_connections
  cluster_settings                       = var.app_service_environment_cluster_settings
  custom_dns_suffix_configuration        = var.app_service_environment_custom_dns_suffix_configuration
  dedicated_host_count                   = var.app_service_environment_dedicated_host_count
  diagnostic_settings                    = var.app_service_environment_diagnostic_settings
  enable_telemetry                       = var.enable_telemetry
  fips_mode_enabled                      = var.app_service_environment_fips_mode_enabled
  front_end_tls_cipher_suite_order       = var.app_service_environment_front_end_tls_cipher_suite_order
  ftp_enabled                            = var.app_service_environment_ftp_enabled
  inbound_ip_address_override            = var.app_service_environment_inbound_ip_address_override
  internal_encryption_enabled            = var.app_service_environment_internal_encryption_enabled
  internal_load_balancing_mode           = var.app_service_environment_internal_load_balancing_mode
  lock                                   = var.app_service_environment_lock
  managed_identities                     = var.app_service_environment_managed_identities
  remote_debug_enabled                   = var.app_service_environment_remote_debug_enabled
  retry                                  = var.app_service_environment_retry
  role_assignments                       = var.app_service_environment_role_assignments
  tags                                   = var.tags
  timeouts                               = var.app_service_environment_timeouts
  tls_1_enabled                          = var.app_service_environment_tls_1_enabled
  upgrade_preference                     = var.app_service_environment_upgrade_preference
  zone_redundancy_enabled                = var.app_service_environment_zone_redundancy_enabled
}
