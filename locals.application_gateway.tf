locals {
  # Auto-generate Application Gateway configuration from web apps if not explicitly provided
  application_gateway_backend_address_pools = var.application_gateway_backend_address_pools != null ? var.application_gateway_backend_address_pools : {
    for key, app in var.web_apps : key => {
      name         = module.naming.resource_names.application_gateway_backend_pool[key]
      fqdns        = [replace(replace(module.web_app[key].resource_uri, "https://", ""), "/", "")]
      ip_addresses = null
    }
  }
  application_gateway_backend_http_settings = var.application_gateway_backend_http_settings != null ? var.application_gateway_backend_http_settings : {
    for key, app in var.web_apps : key => {
      name                                = module.naming.resource_names.application_gateway_http_setting[key]
      port                                = 443
      protocol                            = "Https"
      pick_host_name_from_backend_address = true
      probe_name                          = module.naming.resource_names.application_gateway_probe[key]
      request_timeout                     = 120
    }
  }
  application_gateway_frontend_ports = var.application_gateway_frontend_ports != null ? var.application_gateway_frontend_ports : {
    http = {
      name = "port-80"
      port = 80
    }
    https = {
      name = "port-443"
      port = 443
    }
  }
  application_gateway_http_listeners = var.application_gateway_http_listeners != null ? var.application_gateway_http_listeners : {
    for key, app in var.web_apps : key => {
      name               = module.naming.resource_names.application_gateway_listener[key]
      frontend_port_name = "port-443"
      host_name          = replace(replace(module.web_app[key].resource_uri, "https://", ""), "/", "")
    }
  }
  application_gateway_probe_configurations = var.application_gateway_probe_configurations != null ? var.application_gateway_probe_configurations : {
    for key, app in var.web_apps : key => {
      name                                      = module.naming.resource_names.application_gateway_probe[key]
      host                                      = null
      interval                                  = 30
      timeout                                   = 30
      unhealthy_threshold                       = 3
      protocol                                  = "Https"
      port                                      = null
      path                                      = "/"
      pick_host_name_from_backend_http_settings = true
      minimum_servers                           = null
      match = {
        body        = null
        status_code = ["200-399"]
      }
    }
  }
  application_gateway_request_routing_rules = var.application_gateway_request_routing_rules != null ? var.application_gateway_request_routing_rules : {
    for idx_key in keys(var.web_apps) : idx_key => {
      name                       = module.naming.resource_names.application_gateway_routing_rule[idx_key]
      rule_type                  = "Basic"
      http_listener_name         = module.naming.resource_names.application_gateway_listener[idx_key]
      backend_address_pool_name  = module.naming.resource_names.application_gateway_backend_pool[idx_key]
      backend_http_settings_name = module.naming.resource_names.application_gateway_http_setting[idx_key]
      priority                   = 100 + index(keys(var.web_apps), idx_key)
    }
  }
  # Application Gateway subnet
  application_gateway_subnet_id = var.application_gateway_subnet_resource_id != null ? var.application_gateway_subnet_resource_id : (
    var.virtual_network_enabled && var.virtual_network_resource_id == null && var.application_gateway_enabled ? (
      module.virtual_network[0].subnets["application_gateway"].resource_id
    ) : null
  )
}
