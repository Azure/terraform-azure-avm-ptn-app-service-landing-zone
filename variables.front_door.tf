variable "front_door_additional_endpoints" {
  type = map(object({
    name    = string
    enabled = optional(bool, true)
    tags    = optional(map(string))
  }))
  default     = {}
  description = "(Optional) Additional Front Door endpoints to create, merged with the auto-generated endpoints from web_apps."
  nullable    = false
}

variable "front_door_additional_firewall_policies" {
  type = map(object({
    name                              = string
    resource_group_name               = string
    sku_name                          = string
    enabled                           = optional(bool, true)
    mode                              = string
    request_body_check_enabled        = optional(bool, true)
    redirect_url                      = optional(string)
    custom_block_response_status_code = optional(number)
    custom_block_response_body        = optional(string)
    custom_rules = optional(map(object({
      name                           = string
      enabled                        = optional(bool, true)
      priority                       = optional(number, 1)
      rate_limit_duration_in_minutes = optional(number, 1)
      rate_limit_threshold           = optional(number, 10)
      type                           = string
      action                         = string
      match_conditions = map(object({
        match_variable     = string
        operator           = string
        negation_condition = optional(bool)
        match_values       = list(string)
        selector           = optional(string)
        transforms         = optional(list(string))
      }))
    })), {})
    managed_rules = optional(map(object({
      type    = string
      version = string
      action  = string
      exclusions = optional(map(object({
        match_variable = string
        operator       = string
        selector       = optional(string)
      })), {})
      overrides = optional(map(object({
        rule_group_name = string
        exclusions = optional(map(object({
          match_variable = string
          operator       = string
          selector       = optional(string)
        })), {})
        rules = optional(map(object({
          rule_id = string
          action  = string
          enabled = optional(bool, false)
          exclusions = optional(map(object({
            match_variable = string
            operator       = string
            selector       = optional(string)
          })), {})
        })), {})
      })), {})
    })), {})
    tags = optional(map(string))
  }))
  default     = {}
  description = "(Optional) Additional Front Door firewall policies, merged with the auto-generated WAF policy."
  nullable    = false
}

variable "front_door_additional_origin_groups" {
  type = map(object({
    name = string
    health_probe = optional(map(object({
      interval_in_seconds = number
      path                = optional(string, "/")
      protocol            = string
      request_type        = optional(string, "HEAD")
    })), {})
    load_balancing = map(object({
      additional_latency_in_milliseconds = optional(number, 50)
      sample_size                        = optional(number, 4)
      successful_samples_required        = optional(number, 3)
    }))
  }))
  default     = {}
  description = "(Optional) Additional Front Door origin groups, merged with the auto-generated origin groups from web_apps."
  nullable    = false
}

variable "front_door_additional_origins" {
  type = map(object({
    name                           = string
    origin_group_key               = string
    host_name                      = string
    certificate_name_check_enabled = string
    enabled                        = optional(bool, true)
    http_port                      = optional(number, 80)
    https_port                     = optional(number, 443)
    host_header                    = optional(string, null)
    priority                       = optional(number, 1)
    weight                         = optional(number, 500)
    private_link = optional(map(object({
      request_message        = string
      target_type            = optional(string, null)
      location               = string
      private_link_target_id = string
    })), null)
  }))
  default     = {}
  description = "(Optional) Additional Front Door origins, merged with the auto-generated origins from web_apps."
  nullable    = false
}

variable "front_door_additional_routes" {
  type = map(object({
    name                      = string
    origin_group_key          = string
    origin_keys               = list(string)
    endpoint_key              = string
    forwarding_protocol       = optional(string, "HttpsOnly")
    supported_protocols       = list(string)
    patterns_to_match         = list(string)
    link_to_default_domain    = optional(bool, true)
    https_redirect_enabled    = optional(bool, true)
    custom_domain_keys        = optional(list(string), [])
    enabled                   = optional(bool, true)
    rule_set_names            = optional(list(string))
    cdn_frontdoor_origin_path = optional(string, null)
    cache = optional(map(object({
      query_string_caching_behavior = optional(string, "IgnoreQueryString")
      query_strings                 = optional(list(string))
      compression_enabled           = optional(bool, false)
      content_types_to_compress     = optional(list(string))
    })), {})
  }))
  default     = {}
  description = "(Optional) Additional Front Door routes, merged with the auto-generated routes from web_apps."
  nullable    = false
}

variable "front_door_additional_security_policies" {
  type = map(object({
    name = string
    firewall = object({
      front_door_firewall_policy_key = string
      association = object({
        domain_keys       = optional(list(string), [])
        endpoint_keys     = optional(list(string), [])
        patterns_to_match = list(string)
      })
    })
  }))
  default     = {}
  description = "(Optional) Additional Front Door security policies, merged with the auto-generated security policies."
  nullable    = false
}

variable "front_door_cdn_endpoint_custom_domains" {
  type = map(object({
    cdn_endpoint_key = string
    name             = string
    dns_zone = optional(object({
      is_azure_dns_zone                  = bool
      name                               = string
      cname_record_name                  = string
      ttl                                = number
      tags                               = optional(map(string))
      azure_dns_zone_resource_group_name = optional(string, null)
    }))
    cdn_managed_https = optional(object({
      certificate_type = string
      protocol_type    = string
      tls_version      = optional(string, "TLS12")
    }))
    user_managed_https = optional(object({
      key_vault_certificate_id = optional(string)
      key_vault_secret_id      = optional(string)
      tls_version              = optional(string)
    }))
  }))
  default     = {}
  description = "(Optional) A map of CDN Endpoint Custom Domains to create."
  nullable    = false
}

variable "front_door_cdn_endpoints" {
  type = map(object({
    name                      = string
    tags                      = optional(map(string))
    is_http_allowed           = optional(bool, false)
    is_https_allowed          = optional(bool, true)
    content_types_to_compress = optional(list(string), [])
    geo_filters = optional(map(object({
      relative_path = string
      action        = string
      country_codes = list(string)
    })), {})
    is_compression_enabled        = optional(bool)
    querystring_caching_behaviour = optional(string, "IgnoreQueryString")
    optimization_type             = optional(string)
    origins = map(object({
      name       = string
      host_name  = string
      http_port  = optional(number, 80)
      https_port = optional(number, 443)
    }))
    origin_host_header = optional(string)
    origin_path        = optional(string)
    probe_path         = optional(string)
    global_delivery_rule = optional(object({
      cache_expiration_action = optional(list(object({
        behavior = string
        duration = optional(string)
      })), [])
      cache_key_query_string_action = optional(list(object({
        behavior   = string
        parameters = optional(string)
      })), [])
      modify_request_header_action = optional(list(object({
        action = string
        name   = string
        value  = optional(string)
      })), [])
      modify_response_header_action = optional(list(object({
        action = string
        name   = string
        value  = optional(string)
      })), [])
      url_redirect_action = optional(list(object({
        redirect_type = string
        protocol      = optional(string, "Https")
        hostname      = optional(string)
        path          = optional(string)
        fragment      = optional(string)
        query_string  = optional(string)
      })), [])
      url_rewrite_action = optional(list(object({
        source_pattern          = string
        destination             = string
        preserve_unmatched_path = optional(bool, true)
      })), [])
    }), {})
    delivery_rules = optional(list(object({
      name  = string
      order = number
      cache_expiration_action = optional(object({
        behavior = string
        duration = optional(string)
      }))
      cache_key_query_string_action = optional(object({
        behavior   = string
        parameters = optional(string)
      }))
      cookies_condition = optional(object({
        selector         = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      device_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = list(string)
      }))
      http_version_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = list(string)
      }))
      modify_request_header_action = optional(object({
        action = string
        name   = string
        value  = optional(string)
      }))
      modify_response_header_action = optional(object({
        action = string
        name   = string
        value  = optional(string)
      }))
      post_arg_condition = optional(object({
        selector         = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      query_string_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      remote_address_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
      }))
      request_body_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      request_header_condition = optional(object({
        selector         = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      request_method_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = list(string)
      }))
      request_scheme_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = list(string)
      }))
      request_uri_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      url_file_extension_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      url_file_name_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      url_path_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      url_redirect_action = optional(object({
        redirect_type = string
        protocol      = optional(string, "MatchRequest")
        hostname      = optional(string)
        path          = optional(string)
        fragment      = optional(string)
        query_string  = optional(string)
      }))
      url_rewrite_action = optional(object({
        source_pattern          = string
        destination             = string
        preserve_unmatched_path = optional(bool, true)
      }))
    })))
    diagnostic_setting = optional(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), [])
      metric_categories                        = optional(set(string), [])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    }), null)
  }))
  default     = {}
  description = "(Optional) A map of CDN Endpoints to create on the profile."
  nullable    = false
}

variable "front_door_custom_domains" {
  type = map(object({
    name        = string
    dns_zone_id = optional(string, null)
    host_name   = string
    tls = object({
      certificate_type         = optional(string, "ManagedCertificate")
      cdn_frontdoor_secret_key = optional(string, null)
    })
  }))
  default     = {}
  description = "(Optional) A map of Front Door Custom Domains to create."
  nullable    = false
}

variable "front_door_diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = "(Optional) A map of diagnostic settings for the Front Door profile."
  nullable    = false
}

variable "front_door_enabled" {
  type        = bool
  default     = true
  description = "Whether to create an Azure Front Door profile for ingress to the web apps. Defaults to true."
  nullable    = false
}

variable "front_door_lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = "(Optional) The lock configuration for the Front Door profile resource."
}

variable "front_door_managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = "(Optional) Managed identity configuration for the Front Door profile."
  nullable    = false
}

variable "front_door_metric_alerts" {
  type = map(object({
    name = string
    criterias = optional(list(object({
      metric_namespace       = string
      metric_name            = string
      aggregation            = string
      operator               = string
      threshold              = number
      skip_metric_validation = optional(bool, false)
      dimensions = optional(list(object({
        name     = string
        operator = string
        values   = list(string)
      })))
    })), [])
    actions = optional(list(object({
      action_group_id    = string
      webhook_properties = optional(map(string))
    })), [])
    dynamic_criterias = optional(list(object({
      alert_sensitivity        = string
      aggregation              = string
      operator                 = string
      metric_namespace         = string
      metric_name              = string
      skip_metric_validation   = optional(bool, false)
      evaluation_failure_count = optional(number, 4)
      evaluation_total_count   = optional(number, 4)
      ignore_data_before       = optional(string)
      dimension = optional(list(object({
        name     = string
        operator = string
        values   = list(string)
      })), [])
    })), [])
    application_insights_web_test_location_availability_criterias = optional(list(object({
      component_id          = string
      failed_location_count = number
      web_test_id           = string
    })), [])
    auto_mitigate            = optional(bool, true)
    description              = optional(string)
    enabled                  = optional(bool, true)
    frequency                = optional(string, "PT1M")
    severity                 = optional(number, 3)
    target_resource_type     = optional(string)
    target_resource_location = optional(string)
    window_size              = optional(string, "PT5M")
    tags                     = optional(map(string))
  }))
  default     = {}
  description = "(Optional) A map of metric alerts to create on the Front Door profile."
  nullable    = false
}

variable "front_door_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Azure Front Door profile. Defaults to 'afd-{name}'."
}

variable "front_door_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing Azure Front Door profile. When set, the module will not create a Front Door profile."
}

variable "front_door_response_timeout_seconds" {
  type        = number
  default     = 120
  description = "(Optional) The maximum response timeout in seconds for the Front Door profile. Values between 16 and 240. Defaults to 120."

  validation {
    condition     = var.front_door_response_timeout_seconds >= 16 && var.front_door_response_timeout_seconds <= 240
    error_message = "The response timeout must be between 16 and 240 seconds."
  }
}

variable "front_door_role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = "(Optional) A map of role assignments for the Front Door profile."
  nullable    = false
}

variable "front_door_rule_sets" {
  type        = set(string)
  default     = []
  description = "(Optional) A set of Front Door Rule Set names to create."
}

variable "front_door_rules" {
  type = map(object({
    name              = string
    order             = number
    origin_group_key  = string
    rule_set_name     = string
    behavior_on_match = optional(string, "Continue")
    actions = object({
      url_rewrite_actions = optional(list(object({
        source_pattern          = string
        destination             = string
        preserve_unmatched_path = optional(bool, false)
      })), [])
      url_redirect_actions = optional(list(object({
        redirect_type        = string
        destination_hostname = string
        redirect_protocol    = optional(string, "Https")
        destination_path     = optional(string, "")
        query_string         = optional(string, "")
        destination_fragment = optional(string, "")
      })), [])
      route_configuration_override_actions = optional(list(object({
        set_origin_groupid            = bool
        cache_duration                = optional(string)
        forwarding_protocol           = optional(string, "HttpsOnly")
        query_string_caching_behavior = optional(string)
        query_string_parameters       = optional(list(string))
        compression_enabled           = optional(bool, false)
        cache_behavior                = optional(string)
      })), [])
      request_header_actions = optional(list(object({
        header_action = string
        header_name   = string
        value         = optional(string)
      })), [])
      response_header_actions = optional(list(object({
        header_action = string
        header_name   = string
        value         = optional(string)
      })), [])
    })
    conditions = optional(object({
      remote_address_conditions = optional(list(object({
        operator         = optional(string, "IPMatch")
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
      })), [])
      request_method_conditions = optional(list(object({
        match_values     = list(string)
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
      })), [])
      query_string_conditions = optional(list(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      })), [])
      post_args_conditions = optional(list(object({
        post_args_name   = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      })), [])
      request_uri_conditions = optional(list(object({
        operator         = string
        negate_condition = optional(bool)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      })), [])
      request_header_conditions = optional(list(object({
        header_name      = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      })), [])
      request_body_conditions = optional(list(object({
        operator         = string
        match_values     = list(string)
        negate_condition = optional(bool, false)
        transforms       = optional(list(string))
      })), [])
      request_scheme_conditions = optional(list(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
      })), [])
      url_path_conditions = optional(list(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      })), [])
      url_file_extension_conditions = optional(list(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = list(string)
        transforms       = optional(list(string))
      })), [])
      url_filename_conditions = optional(list(object({
        operator         = string
        match_values     = optional(list(string))
        negate_condition = optional(bool, false)
        transforms       = optional(list(string))
      })), [])
      http_version_conditions = optional(list(object({
        operator         = optional(string, "Equal")
        match_values     = list(string)
        negate_condition = optional(bool, false)
      })), [])
      cookies_conditions = optional(list(object({
        cookie_name      = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      })), [])
      is_device_conditions = optional(list(object({
        operator         = optional(string)
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
      })), [])
      socket_address_conditions = optional(list(object({
        operator         = optional(string, "IPMatch")
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
      })), [])
      client_port_conditions = optional(list(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(number))
      })), [])
      server_port_conditions = optional(list(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = list(number)
      })), [])
      host_name_conditions = optional(list(object({
        operator         = string
        match_values     = optional(list(string))
        transforms       = optional(list(string))
        negate_condition = optional(bool, false)
      })), [])
      ssl_protocol_conditions = optional(list(object({
        match_values     = list(string)
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
      })), [])
    }))
  }))
  default     = {}
  description = "(Optional) A map of Front Door rules to create."
  nullable    = false
}

variable "front_door_secrets" {
  type = map(object({
    name                     = string
    key_vault_certificate_id = string
  }))
  default     = {}
  description = "(Optional) A map of Front Door Secrets to create."
  nullable    = false
}

variable "front_door_sku" {
  type        = string
  default     = "Premium_AzureFrontDoor"
  description = "The SKU of the Azure Front Door profile. 'Premium_AzureFrontDoor' supports WAF managed rules and private link to origins. 'Standard_AzureFrontDoor' is more cost-effective but does not support private link origins."
  nullable    = false

  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.front_door_sku)
    error_message = "The Front Door SKU must be one of: 'Standard_AzureFrontDoor', 'Premium_AzureFrontDoor'."
  }
}

variable "front_door_waf_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable a Web Application Firewall (WAF) policy on the Azure Front Door with Microsoft managed rule sets. Defaults to true."
  nullable    = false
}
