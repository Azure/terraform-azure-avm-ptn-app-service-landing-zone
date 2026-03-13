module "application_gateway" {
  source  = "Azure/avm-res-network-applicationgateway/azurerm"
  version = "0.5.2"
  count   = var.application_gateway_enabled && length(var.web_apps) > 0 ? 1 : 0

  # Required inputs
  backend_address_pools = local.application_gateway_backend_address_pools
  backend_http_settings = local.application_gateway_backend_http_settings
  frontend_ports        = local.application_gateway_frontend_ports
  gateway_ip_configuration = {
    name      = "appGatewayIpConfig"
    subnet_id = local.application_gateway_subnet_id
  }
  http_listeners        = local.application_gateway_http_listeners
  location              = var.location
  name                  = coalesce(var.application_gateway_name, module.naming.resource_names.application_gateway)
  request_routing_rules = local.application_gateway_request_routing_rules
  resource_group_name   = local.resource_group_name
  # Optional inputs
  autoscale_configuration = var.application_gateway_autoscale_configuration
  diagnostic_settings     = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.application_gateway_diagnostic_settings
  enable_telemetry        = var.enable_telemetry
  http2_enable            = var.application_gateway_http2_enabled
  lock                    = var.application_gateway_lock
  managed_identities      = local.application_gateway_effective_managed_identities
  probe_configurations    = local.application_gateway_probe_configurations
  public_ip_address_configuration = {
    public_ip_name    = coalesce(var.application_gateway_public_ip_name, module.naming.resource_names.application_gateway_public_ip)
    allocation_method = "Static"
    sku               = "Standard"
    sku_tier          = "Regional"
    zones             = var.application_gateway_zones
  }
  redirect_configuration      = var.application_gateway_redirect_configurations
  rewrite_rule_set            = var.application_gateway_rewrite_rule_sets
  role_assignments            = var.application_gateway_role_assignments
  sku                         = var.application_gateway_sku
  ssl_certificates            = local.application_gateway_effective_ssl_certificates
  ssl_policy                  = var.application_gateway_ssl_policy
  tags                        = try(coalesce(var.application_gateway_tags, var.tags), {})
  trusted_root_certificate    = var.application_gateway_trusted_root_certificates
  url_path_map_configurations = var.application_gateway_url_path_maps
  waf_configuration           = var.application_gateway_waf_configuration
  zones                       = var.application_gateway_zones
}
