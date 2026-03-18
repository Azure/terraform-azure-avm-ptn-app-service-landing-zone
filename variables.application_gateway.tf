variable "application_gateway_autoscale_configuration" {
  type = object({
    min_capacity = optional(number, 1)
    max_capacity = optional(number, 2)
  })
  default     = {}
  description = "(Optional) Autoscale configuration for the Application Gateway."
}

variable "application_gateway_backend_address_pools" {
  type = map(object({
    name         = string
    fqdns        = optional(set(string))
    ip_addresses = optional(set(string))
  }))
  default     = null
  description = "(Optional) Backend address pools for the Application Gateway. If not set, auto-generated from web apps."
}

variable "application_gateway_backend_http_settings" {
  type = map(object({
    cookie_based_affinity                = optional(string, "Disabled")
    dedicated_backend_connection_enabled = optional(bool, false)
    name                                 = string
    port                                 = number
    protocol                             = string
    affinity_cookie_name                 = optional(string)
    host_name                            = optional(string)
    path                                 = optional(string)
    pick_host_name_from_backend_address  = optional(bool)
    probe_name                           = optional(string)
    request_timeout                      = optional(number)
    trusted_root_certificate_names       = optional(list(string))
    authentication_certificate = optional(list(object({
      name = string
    })))
    connection_draining = optional(object({
      drain_timeout_sec          = number
      enable_connection_draining = bool
    }))
  }))
  default     = null
  description = "(Optional) Backend HTTP settings for the Application Gateway. If not set, auto-generated."
}

variable "application_gateway_diagnostic_settings" {
  type = map(object({
    name = optional(string, null)
    logs = optional(set(object({
      category       = optional(string, null)
      category_group = optional(string, null)
      enabled        = optional(bool, true)
      retention_policy = optional(object({
        days    = optional(number, 0)
        enabled = optional(bool, false)
      }), {})
    })), [])
    metrics = optional(set(object({
      category = optional(string, null)
      enabled  = optional(bool, true)
      retention_policy = optional(object({
        days    = optional(number, 0)
        enabled = optional(bool, false)
      }), {})
    })), [])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = "(Optional) Diagnostic settings for the Application Gateway."
  nullable    = false
}

variable "application_gateway_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether to create an Application Gateway for ingress. Defaults to false. Mutually exclusive with Front Door as the ingress option."
  nullable    = false
}

variable "application_gateway_frontend_ports" {
  type = map(object({
    name = string
    port = number
  }))
  default     = null
  description = "(Optional) Frontend ports for the Application Gateway. If not set, defaults to HTTP (80) and HTTPS (443)."
}

variable "application_gateway_http2_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether HTTP/2 is enabled on the Application Gateway. Defaults to true."
  nullable    = false
}

variable "application_gateway_http_listeners" {
  type = map(object({
    name                           = string
    frontend_port_name             = string
    frontend_ip_configuration_name = optional(string)
    firewall_policy_id             = optional(string)
    require_sni                    = optional(bool)
    host_name                      = optional(string)
    host_names                     = optional(list(string))
    ssl_certificate_name           = optional(string)
    ssl_profile_name               = optional(string)
    custom_error_configuration = optional(list(object({
      status_code           = string
      custom_error_page_url = string
    })))
  }))
  default     = null
  description = "(Optional) HTTP listeners for the Application Gateway. If not set, auto-generated."
}

variable "application_gateway_lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = "(Optional) Controls the resource lock configuration for the Application Gateway."
}

variable "application_gateway_managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = "(Optional) Managed identities for the Application Gateway (e.g., for Key Vault-referenced SSL certificates)."
  nullable    = false
}

variable "application_gateway_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Application Gateway. If not set, defaults to 'agw-{name}'."
}

variable "application_gateway_probe_configurations" {
  type = map(object({
    name                                      = string
    host                                      = optional(string)
    interval                                  = number
    timeout                                   = number
    unhealthy_threshold                       = number
    protocol                                  = string
    port                                      = optional(number)
    path                                      = string
    pick_host_name_from_backend_http_settings = optional(bool)
    minimum_servers                           = optional(number)
    match = optional(object({
      body        = optional(string)
      status_code = optional(list(string))
    }))
  }))
  default     = null
  description = "(Optional) Health probe configurations for the Application Gateway. If not set, auto-generated."
}

variable "application_gateway_public_ip_domain_name_label" {
  type        = string
  default     = null
  description = "(Optional) The domain name label for the public IP of the Application Gateway. If not set, defaults to the same pattern as the web app name. If set, an A DNS record is created for the public IP in the Microsoft Azure DNS system, resulting in an FQDN of `<label>.<region>.cloudapp.azure.com`."
}

variable "application_gateway_public_ip_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the public IP for the Application Gateway. If not set, defaults to 'pip-agw-{name}'."
}

variable "application_gateway_redirect_configurations" {
  type = map(object({
    include_path         = optional(bool)
    include_query_string = optional(bool)
    name                 = string
    redirect_type        = string
    target_listener_name = optional(string)
    target_url           = optional(string)
  }))
  default     = null
  description = "(Optional) Redirect configurations for the Application Gateway."
}

variable "application_gateway_request_routing_rules" {
  type = map(object({
    name                        = string
    rule_type                   = string
    http_listener_name          = string
    backend_address_pool_name   = string
    priority                    = number
    url_path_map_name           = optional(string)
    backend_http_settings_name  = string
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name       = optional(string)
  }))
  default     = null
  description = "(Optional) Request routing rules for the Application Gateway. If not set, auto-generated."
}

variable "application_gateway_rewrite_rule_sets" {
  type = map(object({
    name = string
    rewrite_rules = optional(map(object({
      name          = string
      rule_sequence = number
      conditions = optional(map(object({
        ignore_case = optional(bool)
        negate      = optional(bool)
        pattern     = string
        variable    = string
      })))
      request_header_configurations = optional(map(object({
        header_name  = string
        header_value = string
      })))
      response_header_configurations = optional(map(object({
        header_name  = string
        header_value = string
      })))
      url = optional(object({
        components   = optional(string)
        path         = optional(string)
        query_string = optional(string)
        reroute      = optional(bool)
      }))
    })))
  }))
  default     = null
  description = "(Optional) Rewrite rule sets for the Application Gateway."
}

variable "application_gateway_role_assignments" {
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
  description = "(Optional) A map of role assignments to create on the Application Gateway."
  nullable    = false
}

variable "application_gateway_sku" {
  type = object({
    name     = string
    tier     = string
    capacity = optional(number, 2)
  })
  default = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }
  description = "(Optional) The SKU configuration for the Application Gateway. Defaults to WAF_v2 with capacity 2."
  nullable    = false
}

variable "application_gateway_ssl_certificates" {
  type = map(object({
    name                = string
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default     = null
  description = "(Optional) SSL certificates for HTTPS termination on the Application Gateway."
  sensitive   = true
}

variable "application_gateway_ssl_policy" {
  type = object({
    cipher_suites        = optional(list(string))
    disabled_protocols   = optional(list(string))
    min_protocol_version = optional(string, "TLSv1_2")
    policy_name          = optional(string)
    policy_type          = optional(string)
  })
  default     = null
  description = "(Optional) SSL policy for the Application Gateway."
}

variable "application_gateway_subnet_address_prefix" {
  type        = string
  default     = "10.0.4.0/24"
  description = "(Optional) The address prefix for the Application Gateway subnet. Defaults to '10.0.4.0/24'."
  nullable    = false
}

variable "application_gateway_subnet_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of an existing subnet for the Application Gateway. When set, a new subnet will not be created."
}

variable "application_gateway_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to apply to the Application Gateway. If null, the module-level tags are used."
}

variable "application_gateway_trusted_root_certificates" {
  type = map(object({
    data                = optional(string)
    key_vault_secret_id = optional(string)
    name                = string
  }))
  default     = null
  description = "(Optional) Trusted root certificates for end-to-end SSL on the Application Gateway."
}

variable "application_gateway_url_path_maps" {
  type = map(object({
    name                                = string
    default_redirect_configuration_name = optional(string)
    default_rewrite_rule_set_name       = optional(string)
    default_backend_http_settings_name  = optional(string)
    default_backend_address_pool_name   = optional(string)
    path_rules = map(object({
      name                        = string
      paths                       = list(string)
      backend_address_pool_name   = optional(string)
      backend_http_settings_name  = optional(string)
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name       = optional(string)
      firewall_policy_id          = optional(string)
    }))
  }))
  default     = null
  description = "(Optional) URL path maps for path-based routing on the Application Gateway."
}

variable "application_gateway_waf_configuration" {
  type = object({
    enabled                  = bool
    file_upload_limit_mb     = optional(number)
    firewall_mode            = string
    max_request_body_size_kb = optional(number)
    request_body_check       = optional(bool)
    rule_set_type            = optional(string)
    rule_set_version         = string
    disabled_rule_group = optional(list(object({
      rule_group_name = string
      rules           = optional(list(number))
    })))
    exclusion = optional(list(object({
      match_variable          = string
      selector                = optional(string)
      selector_match_operator = optional(string)
    })))
  })
  default = {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
  description = "(Optional) WAF configuration for the Application Gateway. Defaults to Prevention mode with OWASP 3.2."
}

variable "application_gateway_zones" {
  type        = set(string)
  default     = ["1", "2", "3"]
  description = "(Optional) Availability zones for the Application Gateway. Defaults to all three zones."
  nullable    = false
}
