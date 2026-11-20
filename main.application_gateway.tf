module "application_gateway" {
  source  = "Azure/avm-res-network-applicationgateway/azurerm"
  version = "0.6.0"
  count   = var.application_gateway_enabled && length(var.web_apps) > 0 ? 1 : 0

  location                = var.location
  name                    = local.application_gateway_name
  parent_id               = local.resource_group_id
  autoscale_configuration = var.application_gateway_autoscale_configuration
  backend_address_pools = [
    for pool in values(local.application_gateway_backend_address_pools) : {
      name = pool.name
      backend_addresses = concat(
        [for fqdn in coalesce(pool.fqdns, []) : { fqdn = fqdn }],
        [for ip in coalesce(pool.ip_addresses, []) : { ip_address = ip }]
      )
    }
  ]
  backend_http_settings_collection = [
    for settings in values(local.application_gateway_backend_http_settings) : {
      name                                = settings.name
      affinity_cookie_name                = settings.affinity_cookie_name
      cookie_based_affinity               = settings.cookie_based_affinity
      dedicated_backend_connection        = settings.dedicated_backend_connection_enabled
      host_name                           = settings.host_name
      path                                = settings.path
      pick_host_name_from_backend_address = settings.pick_host_name_from_backend_address
      port                                = settings.port
      protocol                            = settings.protocol
      request_timeout                     = settings.request_timeout
      probe = settings.probe_name == null ? null : {
        id = "${local.application_gateway_resource_id}/probes/${settings.probe_name}"
      }
      authentication_certificates = settings.authentication_certificate == null ? null : [
        for cert in settings.authentication_certificate : {
          id = "${local.application_gateway_resource_id}/authenticationCertificates/${cert.name}"
        }
      ]
      trusted_root_certificates = settings.trusted_root_certificate_names == null ? null : [
        for name in settings.trusted_root_certificate_names : {
          id = "${local.application_gateway_resource_id}/trustedRootCertificates/${name}"
        }
      ]
      connection_draining = settings.connection_draining == null ? null : {
        drain_timeout_in_sec = settings.connection_draining.drain_timeout_sec
        enabled              = settings.connection_draining.enable_connection_draining
      }
    }
  ]
  diagnostic_settings = var.alz_platform_landing_zone_diagnostic_settings_mode_enabled ? {} : local.application_gateway_diagnostic_settings
  enable_http2        = var.application_gateway_http2_enabled
  enable_telemetry    = var.enable_telemetry
  frontend_ip_configurations = [{
    name                  = "${local.application_gateway_name}-feip"
    public_ip_address_key = "default"
  }]
  frontend_ports = values(local.application_gateway_frontend_ports)
  gateway_ip_configurations = [{
    name   = "appGatewayIpConfig"
    subnet = { id = local.application_gateway_subnet_id }
  }]
  http_listeners = [
    for listener in values(local.application_gateway_http_listeners) : {
      name                           = listener.name
      custom_error_configurations    = listener.custom_error_configuration
      firewall_policy                = listener.firewall_policy_id == null ? null : { id = listener.firewall_policy_id }
      frontend_ip_configuration      = { id = "${local.application_gateway_resource_id}/frontendIPConfigurations/${coalesce(listener.frontend_ip_configuration_name, "${local.application_gateway_name}-feip")}" }
      frontend_port                  = { id = "${local.application_gateway_resource_id}/frontendPorts/${listener.frontend_port_name}" }
      host_name                      = listener.host_name
      host_names                     = listener.host_names
      protocol                       = listener.ssl_certificate_name == null ? "Http" : "Https"
      require_server_name_indication = listener.require_sni
      ssl_certificate                = listener.ssl_certificate_name == null ? null : { id = "${local.application_gateway_resource_id}/sslCertificates/${listener.ssl_certificate_name}" }
      ssl_profile                    = listener.ssl_profile_name == null ? null : { id = "${local.application_gateway_resource_id}/sslProfiles/${listener.ssl_profile_name}" }
    }
  ]
  lock               = var.application_gateway_lock
  managed_identities = local.application_gateway_effective_managed_identities
  probes = [
    for probe in values(local.application_gateway_probe_configurations) : {
      name                                      = probe.name
      host                                      = probe.host
      interval                                  = probe.interval
      timeout                                   = probe.timeout
      unhealthy_threshold                       = probe.unhealthy_threshold
      protocol                                  = probe.protocol
      port                                      = probe.port
      path                                      = probe.path
      pick_host_name_from_backend_http_settings = probe.pick_host_name_from_backend_http_settings
      min_servers                               = probe.minimum_servers
      match = probe.match == null ? null : {
        body         = probe.match.body
        status_codes = probe.match.status_code
      }
    }
  ]
  public_ip_addresses = {
    default = {
      name              = coalesce(var.application_gateway_public_ip_name, module.naming.resource_names.application_gateway_public_ip)
      domain_name_label = coalesce(var.application_gateway_public_ip_domain_name_label, module.naming.resource_names.application_gateway_public_ip_domain_name_label)
      zones             = tolist(var.application_gateway_zones)
    }
  }
  redirect_configurations = var.application_gateway_redirect_configurations == null ? null : [
    for redirect in values(var.application_gateway_redirect_configurations) : {
      name                 = redirect.name
      include_path         = redirect.include_path
      include_query_string = redirect.include_query_string
      redirect_type        = redirect.redirect_type
      target_listener      = redirect.target_listener_name == null ? null : { id = "${local.application_gateway_resource_id}/httpListeners/${redirect.target_listener_name}" }
      target_url           = redirect.target_url
    }
  ]
  request_routing_rules = [
    for rule in values(local.application_gateway_request_routing_rules) : {
      name                   = rule.name
      rule_type              = rule.rule_type
      priority               = rule.priority
      http_listener          = { id = "${local.application_gateway_resource_id}/httpListeners/${rule.http_listener_name}" }
      backend_address_pool   = rule.backend_address_pool_name == null ? null : { id = "${local.application_gateway_resource_id}/backendAddressPools/${rule.backend_address_pool_name}" }
      backend_http_settings  = rule.backend_http_settings_name == null ? null : { id = "${local.application_gateway_resource_id}/backendHttpSettingsCollection/${rule.backend_http_settings_name}" }
      url_path_map           = rule.url_path_map_name == null ? null : { id = "${local.application_gateway_resource_id}/urlPathMaps/${rule.url_path_map_name}" }
      redirect_configuration = rule.redirect_configuration_name == null ? null : { id = "${local.application_gateway_resource_id}/redirectConfigurations/${rule.redirect_configuration_name}" }
      rewrite_rule_set       = rule.rewrite_rule_set_name == null ? null : { id = "${local.application_gateway_resource_id}/rewriteRuleSets/${rule.rewrite_rule_set_name}" }
    }
  ]
  rewrite_rule_sets = var.application_gateway_rewrite_rule_sets == null ? null : [
    for rule_set in values(var.application_gateway_rewrite_rule_sets) : {
      name = rule_set.name
      rewrite_rules = rule_set.rewrite_rules == null ? null : [
        for rule in values(rule_set.rewrite_rules) : {
          name          = rule.name
          rule_sequence = rule.rule_sequence
          conditions    = rule.conditions == null ? null : values(rule.conditions)
          action_set = {
            request_header_configurations  = rule.request_header_configurations == null ? null : values(rule.request_header_configurations)
            response_header_configurations = rule.response_header_configurations == null ? null : values(rule.response_header_configurations)
            url_configuration = rule.url == null ? null : {
              modified_path         = rule.url.components == "query_string_only" ? null : rule.url.path
              modified_query_string = rule.url.components == "path_only" ? null : rule.url.query_string
              reroute               = rule.url.reroute
            }
          }
        }
      ]
    }
  ]
  role_assignments = var.application_gateway_role_assignments
  sku = {
    name     = var.application_gateway_sku.name
    tier     = var.application_gateway_sku.tier
    capacity = var.application_gateway_autoscale_configuration == null ? var.application_gateway_sku.capacity : null
  }
  ssl_certificates = nonsensitive(local.application_gateway_effective_ssl_certificates == null) ? null : [
    for key in nonsensitive(keys(local.application_gateway_effective_ssl_certificates)) : {
      name                = nonsensitive(local.application_gateway_effective_ssl_certificates[key].name)
      data                = nonsensitive(local.application_gateway_effective_ssl_certificates[key].data == null) ? null : local.application_gateway_effective_ssl_certificates[key].data
      password            = nonsensitive(local.application_gateway_effective_ssl_certificates[key].password == null) ? null : local.application_gateway_effective_ssl_certificates[key].password
      key_vault_secret_id = nonsensitive(local.application_gateway_effective_ssl_certificates[key].key_vault_secret_id == null) ? null : local.application_gateway_effective_ssl_certificates[key].key_vault_secret_id
    }
  ]
  ssl_policy = var.application_gateway_ssl_policy == null ? null : {
    cipher_suites          = var.application_gateway_ssl_policy.cipher_suites
    disabled_ssl_protocols = var.application_gateway_ssl_policy.disabled_protocols
    min_protocol_version   = var.application_gateway_ssl_policy.min_protocol_version
    policy_name            = var.application_gateway_ssl_policy.policy_name
    policy_type            = var.application_gateway_ssl_policy.policy_type
  }
  tags                      = try(coalesce(var.application_gateway_tags, var.tags), {})
  trusted_root_certificates = var.application_gateway_trusted_root_certificates == null ? null : values(var.application_gateway_trusted_root_certificates)
  url_path_maps = var.application_gateway_url_path_maps == null ? null : [
    for path_map in values(var.application_gateway_url_path_maps) : {
      name                           = path_map.name
      default_backend_address_pool   = path_map.default_backend_address_pool_name == null ? null : { id = "${local.application_gateway_resource_id}/backendAddressPools/${path_map.default_backend_address_pool_name}" }
      default_backend_http_settings  = path_map.default_backend_http_settings_name == null ? null : { id = "${local.application_gateway_resource_id}/backendHttpSettingsCollection/${path_map.default_backend_http_settings_name}" }
      default_redirect_configuration = path_map.default_redirect_configuration_name == null ? null : { id = "${local.application_gateway_resource_id}/redirectConfigurations/${path_map.default_redirect_configuration_name}" }
      default_rewrite_rule_set       = path_map.default_rewrite_rule_set_name == null ? null : { id = "${local.application_gateway_resource_id}/rewriteRuleSets/${path_map.default_rewrite_rule_set_name}" }
      path_rules = [
        for rule in values(path_map.path_rules) : {
          name                   = rule.name
          paths                  = rule.paths
          backend_address_pool   = rule.backend_address_pool_name == null ? null : { id = "${local.application_gateway_resource_id}/backendAddressPools/${rule.backend_address_pool_name}" }
          backend_http_settings  = rule.backend_http_settings_name == null ? null : { id = "${local.application_gateway_resource_id}/backendHttpSettingsCollection/${rule.backend_http_settings_name}" }
          firewall_policy        = rule.firewall_policy_id == null ? null : { id = rule.firewall_policy_id }
          redirect_configuration = rule.redirect_configuration_name == null ? null : { id = "${local.application_gateway_resource_id}/redirectConfigurations/${rule.redirect_configuration_name}" }
          rewrite_rule_set       = rule.rewrite_rule_set_name == null ? null : { id = "${local.application_gateway_resource_id}/rewriteRuleSets/${rule.rewrite_rule_set_name}" }
        }
      ]
    }
  ]
  web_application_firewall_configuration = var.application_gateway_waf_configuration == null ? null : {
    enabled                     = var.application_gateway_waf_configuration.enabled
    disabled_rule_groups        = var.application_gateway_waf_configuration.disabled_rule_group
    exclusions                  = var.application_gateway_waf_configuration.exclusion
    file_upload_limit_in_mb     = var.application_gateway_waf_configuration.file_upload_limit_mb
    firewall_mode               = var.application_gateway_waf_configuration.firewall_mode
    max_request_body_size_in_kb = var.application_gateway_waf_configuration.max_request_body_size_kb
    request_body_check          = var.application_gateway_waf_configuration.request_body_check
    rule_set_type               = coalesce(var.application_gateway_waf_configuration.rule_set_type, "OWASP")
    rule_set_version            = var.application_gateway_waf_configuration.rule_set_version
  }
  zones = tolist(var.application_gateway_zones)
}
