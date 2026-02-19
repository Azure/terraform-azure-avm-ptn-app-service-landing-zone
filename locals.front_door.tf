locals {
  # Front Door endpoints - one per web app
  front_door_endpoints = {
    for key, app in var.web_apps : key => {
      name = "fde-${app.name}"
    }
  }
  # Front Door WAF policy
  front_door_firewall_policies = var.front_door_waf_enabled ? {
    default_waf = {
      name                = "wafpolicy${replace(var.name, "-", "")}"
      resource_group_name = var.resource_group_name
      sku_name            = var.front_door_sku
      mode                = "Prevention"
      managed_rules = {
        drs = {
          type    = "Microsoft_DefaultRuleSet"
          version = "2.1"
          action  = "Block"
        }
        botmanager = {
          type    = "Microsoft_BotManagerRuleSet"
          version = "1.0"
          action  = "Block"
        }
      }
    }
  } : {}
  # Front Door origin groups - one per web app
  front_door_origin_groups = {
    for key, app in var.web_apps : key => {
      name = "fdog-${app.name}"
      health_probe = {
        hp1 = {
          interval_in_seconds = 100
          path                = "/"
          protocol            = "Https"
          request_type        = "HEAD"
        }
      }
      load_balancing = {
        lb1 = {
          additional_latency_in_milliseconds = 0
          sample_size                        = 4
          successful_samples_required        = 3
        }
      }
    }
  }
  # Front Door origins - one per web app, with optional private link
  front_door_origins = {
    for key, app in var.web_apps : key => {
      name                           = "fdo-${app.name}"
      origin_group_key               = key
      host_name                      = replace(replace(module.web_app[key].resource_uri, "https://", ""), "/", "")
      certificate_name_check_enabled = "true"
      http_port                      = 80
      https_port                     = 443
      priority                       = 1
      weight                         = 1000
      private_link = var.front_door_sku == "Premium_AzureFrontDoor" && local.virtual_network_enabled ? {
        pl = {
          request_message        = "Please approve this private link connection"
          target_type            = "sites"
          location               = var.location
          private_link_target_id = module.web_app[key].resource_id
        }
      } : null
    }
  }
  # Front Door routes - one per web app
  front_door_routes = {
    for key, app in var.web_apps : key => {
      name                   = "fdr-${app.name}"
      endpoint_key           = key
      origin_group_key       = key
      origin_keys            = [key]
      patterns_to_match      = ["/*"]
      supported_protocols    = ["Http", "Https"]
      https_redirect_enabled = true
      forwarding_protocol    = "HttpsOnly"
    }
  }
  # Front Door security policies - apply WAF to all endpoints
  front_door_security_policies = var.front_door_waf_enabled && length(var.web_apps) > 0 ? {
    default_security = {
      name = "secpol${replace(var.name, "-", "")}"
      firewall = {
        front_door_firewall_policy_key = "default_waf"
        association = {
          endpoint_keys     = keys(var.web_apps)
          patterns_to_match = ["/*"]
        }
      }
    }
  } : {}
}
