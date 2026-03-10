variable "web_app_slot_sensitive_app_settings" {
  type        = map(map(map(string)))
  default     = {}
  description = <<DESCRIPTION
A map of sensitive app settings for deployment slots, keyed by web app key then slot key.
The structure is: { web_app_key = { slot_key = { setting_name = setting_value } } }
DESCRIPTION
  sensitive   = true
}

variable "web_app_slots_storage_shares_to_mount_sensitive_values" {
  type        = map(map(string))
  default     = {}
  description = <<DESCRIPTION
A map of sensitive storage access keys for slot storage shares, keyed by web app key.
The structure is: { web_app_key = { storage_mount_key = access_key_value } }
DESCRIPTION
  sensitive   = true
}

variable "web_apps" {
  type = map(object({
    name    = string
    kind    = optional(string, "webapp")
    os_type = optional(string, null)

    all_child_resources_inherit_tags = optional(bool, true)
    always_ready = optional(map(object({
      name           = optional(string)
      instance_count = optional(number, 0)
    })), {})
    app_service_active_slot = optional(object({
      slot_key                 = optional(string)
      overwrite_network_config = optional(bool, true)
    }), null)
    app_settings                           = optional(map(string), {})
    application_insights_connection_string = optional(string, null)
    application_insights_key               = optional(string, null)
    auth_settings = optional(object({
      additional_login_parameters    = optional(map(string))
      allowed_external_redirect_urls = optional(list(string))
      default_provider               = optional(string)
      enabled                        = optional(bool, false)
      issuer                         = optional(string)
      runtime_version                = optional(string)
      token_refresh_extension_hours  = optional(number, 72)
      token_store_enabled            = optional(bool, false)
      unauthenticated_client_action  = optional(string)
      active_directory = optional(object({
        client_id                  = optional(string)
        allowed_audiences          = optional(list(string))
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
      }))
      facebook = optional(object({
        app_id                  = optional(string)
        app_secret              = optional(string)
        app_secret_setting_name = optional(string)
        oauth_scopes            = optional(list(string))
      }))
      github = optional(object({
        client_id                  = optional(string)
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        oauth_scopes               = optional(list(string))
      }))
      google = optional(object({
        client_id                  = optional(string)
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        oauth_scopes               = optional(list(string))
      }))
      microsoft = optional(object({
        client_id                  = optional(string)
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        oauth_scopes               = optional(list(string))
      }))
      twitter = optional(object({
        consumer_key                 = optional(string)
        consumer_secret              = optional(string)
        consumer_secret_setting_name = optional(string)
      }))
    }), null)
    auth_settings_v2 = optional(object({
      auth_enabled                           = optional(bool, false)
      config_file_path                       = optional(string)
      excluded_paths                         = optional(list(string))
      forward_proxy_convention               = optional(string, "NoProxy")
      forward_proxy_custom_host_header_name  = optional(string)
      forward_proxy_custom_proto_header_name = optional(string)
      http_route_api_prefix                  = optional(string, "/.auth")
      redirect_to_provider                   = optional(string)
      require_authentication                 = optional(bool, false)
      require_https                          = optional(bool, true)
      runtime_version                        = optional(string, "~1")
      unauthenticated_client_action          = optional(string, "RedirectToLoginPage")
      identity_providers = optional(object({
        apple = optional(object({
          enabled = optional(bool)
          login = optional(object({
            scopes = optional(list(string))
          }))
          registration = optional(object({
            client_id                  = optional(string)
            client_secret_setting_name = optional(string)
          }))
        }))
        azure_active_directory = optional(object({
          enabled             = optional(bool)
          is_auto_provisioned = optional(bool)
          login = optional(object({
            disable_www_authenticate = optional(bool)
            login_parameters         = optional(list(string))
          }))
          registration = optional(object({
            client_id                                          = optional(string)
            client_secret_certificate_issuer                   = optional(string)
            client_secret_certificate_subject_alternative_name = optional(string)
            client_secret_certificate_thumbprint               = optional(string)
            client_secret_setting_name                         = optional(string)
            open_id_issuer                                     = optional(string)
          }))
          validation = optional(object({
            allowed_audiences = optional(list(string))
            default_authorization_policy = optional(object({
              allowed_applications = optional(list(string))
              allowed_principals = optional(object({
                groups     = optional(list(string))
                identities = optional(list(string))
              }))
            }))
            jwt_claim_checks = optional(object({
              allowed_client_applications = optional(list(string))
              allowed_groups              = optional(list(string))
            }))
          }))
        }))
        azure_static_web_apps = optional(object({
          enabled = optional(bool)
          registration = optional(object({
            client_id = optional(string)
          }))
        }))
        custom_open_id_connect_providers = optional(map(object({
          enabled = optional(bool)
          login = optional(object({
            name_claim_type = optional(string)
            scopes          = optional(list(string))
          }))
          registration = optional(object({
            client_id = optional(string)
            client_credential = optional(object({
              method                     = optional(string)
              client_secret_setting_name = optional(string)
            }))
            open_id_connect_configuration = optional(object({
              authorization_endpoint           = optional(string)
              certification_uri                = optional(string)
              issuer                           = optional(string)
              token_endpoint                   = optional(string)
              well_known_open_id_configuration = optional(string)
            }))
          }))
        })))
        facebook = optional(object({
          enabled           = optional(bool)
          graph_api_version = optional(string)
          login = optional(object({
            scopes = optional(list(string))
          }))
          registration = optional(object({
            app_id                  = optional(string)
            app_secret_setting_name = optional(string)
          }))
        }))
        github = optional(object({
          enabled = optional(bool)
          login = optional(object({
            scopes = optional(list(string))
          }))
          registration = optional(object({
            client_id                  = optional(string)
            client_secret_setting_name = optional(string)
          }))
        }))
        google = optional(object({
          enabled = optional(bool)
          login = optional(object({
            scopes = optional(list(string))
          }))
          registration = optional(object({
            client_id                  = optional(string)
            client_secret_setting_name = optional(string)
          }))
          validation = optional(object({
            allowed_audiences = optional(list(string))
          }))
        }))
        legacy_microsoft_account = optional(object({
          enabled = optional(bool)
          login = optional(object({
            scopes = optional(list(string))
          }))
          registration = optional(object({
            client_id                  = optional(string)
            client_secret_setting_name = optional(string)
          }))
          validation = optional(object({
            allowed_audiences = optional(list(string))
          }))
        }))
        twitter = optional(object({
          enabled = optional(bool)
          registration = optional(object({
            consumer_key                 = optional(string)
            consumer_secret_setting_name = optional(string)
          }))
        }))
      }))
      login = optional(object({
        allowed_external_redirect_urls = optional(list(string))
        cookie_expiration = optional(object({
          convention         = optional(string, "FixedTime")
          time_to_expiration = optional(string, "08:00:00")
        }))
        nonce = optional(object({
          nonce_expiration_interval = optional(string, "00:05:00")
          validate_nonce            = optional(bool, true)
        }))
        preserve_url_fragments_for_logins = optional(bool, false)
        routes = optional(object({
          logout_endpoint = optional(string)
        }))
        token_store = optional(object({
          azure_blob_storage = optional(object({
            sas_url_setting_name = optional(string)
          }))
          enabled = optional(bool, false)
          file_system = optional(object({
            directory = optional(string)
          }))
          token_refresh_extension_hours = optional(number, 72)
        }))
      }))
    }), null)
    auto_generated_domain_name_label_scope = optional(string, null)
    backup = optional(map(object({
      enabled             = optional(bool, true)
      name                = optional(string)
      storage_account_url = optional(string)
      schedule = optional(map(object({
        frequency_interval       = optional(number)
        frequency_unit           = optional(string)
        keep_at_least_one_backup = optional(bool)
        retention_period_days    = optional(number)
        start_time               = optional(string)
      })))
    })), {})
    builtin_logging_enabled              = optional(bool, true)
    bundle_version                       = optional(string, "[1.*, 2.0.0)")
    client_affinity_enabled              = optional(bool, false)
    client_affinity_partitioning_enabled = optional(bool, null)
    client_affinity_proxy_enabled        = optional(bool, null)
    client_certificate_enabled           = optional(bool, false)
    client_certificate_exclusion_paths   = optional(string, null)
    client_certificate_mode              = optional(string, "Required")
    connection_strings = optional(map(object({
      name  = optional(string)
      type  = optional(string)
      value = optional(string)
    })), {})
    container_size               = optional(number, null)
    content_share_force_disabled = optional(bool, false)
    custom_domains = optional(map(object({
      slot_as_target               = optional(bool, false)
      app_service_slot_key         = optional(string)
      create_certificate           = optional(bool, false)
      certificate_name             = optional(string)
      certificate_location         = optional(string)
      pfx_blob                     = optional(string)
      pfx_password                 = optional(string)
      hostname                     = optional(string)
      app_service_name             = optional(string)
      app_service_plan_resource_id = optional(string)
      key_vault_secret_id          = optional(string)
      key_vault_id                 = optional(string)
      zone_resource_group_name     = optional(string)
      resource_group_name          = optional(string)
      ssl_state                    = optional(string)
      inherit_tags                 = optional(bool, true)
      tags                         = optional(map(string), {})
      thumbprint                   = optional(string)
      thumbprint_key               = optional(string)
      ttl                          = optional(number, 300)
      validation_type              = optional(string, "cname-delegation")
      create_cname_records         = optional(bool, false)
      cname_name                   = optional(string)
      cname_zone_name              = optional(string)
      cname_record                 = optional(string)
      cname_target_resource_id     = optional(string)
      create_txt_records           = optional(bool, false)
      txt_name                     = optional(string)
      txt_zone_name                = optional(string)
      txt_records                  = optional(map(object({ value = string })))
    })), {})
    daily_memory_time_quota = optional(number, 0)
    dapr_config = optional(object({
      app_id                = optional(string)
      app_port              = optional(number)
      enable_api_logging    = optional(bool)
      enabled               = optional(bool)
      http_max_request_size = optional(number)
      http_read_buffer_size = optional(number)
      log_level             = optional(string)
    }), null)
    deployment_slots = optional(map(object({
      name                                   = optional(string)
      auto_generated_domain_name_label_scope = optional(string)
      client_affinity_enabled                = optional(bool, false)
      client_affinity_partitioning_enabled   = optional(bool)
      client_affinity_proxy_enabled          = optional(bool)
      client_certificate_enabled             = optional(bool, false)
      client_certificate_exclusion_paths     = optional(string, null)
      client_certificate_mode                = optional(string, "Required")
      container_size                         = optional(number)
      dapr_config = optional(object({
        app_id                = optional(string)
        app_port              = optional(number)
        enable_api_logging    = optional(bool)
        enabled               = optional(bool)
        http_max_request_size = optional(number)
        http_read_buffer_size = optional(number)
        log_level             = optional(string)
      }))
      dns_configuration = optional(object({
        dns_alt_server            = optional(string)
        dns_max_cache_timeout     = optional(number)
        dns_retry_attempt_count   = optional(number)
        dns_retry_attempt_timeout = optional(number)
        dns_servers               = optional(list(string))
      }))
      enabled                                  = optional(bool, true)
      end_to_end_encryption_enabled            = optional(bool)
      ftp_publish_basic_authentication_enabled = optional(bool, false)
      hosting_environment_id                   = optional(string)
      host_names_disabled                      = optional(bool)
      https_only                               = optional(bool, true)
      hyper_v                                  = optional(bool)
      ip_mode                                  = optional(string)
      key_vault_reference_identity             = optional(string, null)
      managed_environment_id                   = optional(string)
      public_network_access_enabled            = optional(bool, false)
      redundancy_mode                          = optional(string)
      resource_config = optional(object({
        cpu    = optional(number)
        memory = optional(string)
      }))
      scm_site_also_stopped                          = optional(bool)
      server_farm_id                                 = optional(string, null)
      ssh_enabled                                    = optional(bool)
      storage_account_required                       = optional(bool)
      tags                                           = optional(map(string))
      virtual_network_subnet_id                      = optional(string, null)
      vnet_route_all_traffic                         = optional(bool, false)
      vnet_application_traffic_enabled               = optional(bool, false)
      vnet_backup_restore_enabled                    = optional(bool, false)
      vnet_content_share_enabled                     = optional(bool, false)
      vnet_image_pull_enabled                        = optional(bool, false)
      webdeploy_publish_basic_authentication_enabled = optional(bool, false)
      workload_profile_name                          = optional(string)
      app_settings                                   = optional(map(string), {})
      site_config = optional(object({
        always_on             = optional(bool, true)
        api_definition_url    = optional(string)
        api_management_api_id = optional(string)
        app_command_line      = optional(string)
        app_scale_limit       = optional(number)
        auto_heal_enabled     = optional(bool)
        auto_heal_rules = optional(object({
          actions = optional(object({
            action_type = string
            custom_action = optional(object({
              exe        = string
              parameters = optional(string)
            }))
            min_process_execution_time = optional(string, "00:00:00")
          }))
          triggers = optional(object({
            private_bytes_in_kb = optional(number)
            requests = optional(object({
              count         = number
              time_interval = string
            }))
            slow_requests = optional(object({
              count         = number
              time_interval = string
              time_taken    = string
              path          = optional(string)
            }))
            slow_requests_with_path = optional(list(object({
              count         = number
              time_interval = string
              time_taken    = string
              path          = optional(string)
            })), [])
            status_codes = optional(list(object({
              count         = number
              time_interval = string
              status        = number
              path          = optional(string)
              sub_status    = optional(number)
              win32_status  = optional(number)
            })), [])
            status_codes_range = optional(list(object({
              count         = number
              time_interval = string
              status_codes  = string
              path          = optional(string)
            })), [])
          }))
        }))
        auto_swap_slot_name                           = optional(string)
        container_registry_managed_identity_client_id = optional(string)
        container_registry_use_managed_identity       = optional(bool)
        cors = optional(object({
          allowed_origins     = optional(list(string))
          support_credentials = optional(bool, false)
        }))
        default_documents              = optional(list(string))
        detailed_error_logging_enabled = optional(bool)
        document_root                  = optional(string)
        dotnet_framework_version       = optional(string, "v4.0")
        elastic_instance_minimum       = optional(number)
        elastic_web_app_scale_limit    = optional(number)
        experiments = optional(object({
          ramp_up_rules = optional(list(object({
            action_host_name             = optional(string)
            change_decision_callback_url = optional(string)
            change_interval_in_minutes   = optional(number)
            change_step                  = optional(number)
            max_reroute_percentage       = optional(number)
            min_reroute_percentage       = optional(number)
            name                         = optional(string)
            reroute_percentage           = optional(number)
          })), [])
        }))
        ftps_state = optional(string, "FtpsOnly")
        handler_mappings = optional(list(object({
          arguments        = optional(string)
          extension        = optional(string)
          script_processor = optional(string)
        })))
        health_check_path    = optional(string)
        http2_enabled        = optional(bool, false)
        http20_proxy_flag    = optional(number)
        http_logging_enabled = optional(bool)
        ip_restriction = optional(list(object({
          action                    = optional(string, "Allow")
          ip_address                = optional(string)
          name                      = optional(string)
          priority                  = optional(number, 65000)
          service_tag               = optional(string)
          virtual_network_subnet_id = optional(string)
          headers = optional(object({
            x_azure_fdid      = optional(list(string))
            x_fd_health_probe = optional(list(string))
            x_forwarded_for   = optional(list(string))
            x_forwarded_host  = optional(list(string))
          }))
        })), [])
        ip_restriction_default_action = optional(string, "Allow")
        java_container                = optional(string)
        java_container_version        = optional(string)
        java_version                  = optional(string)
        limits = optional(object({
          max_disk_size_in_mb = optional(number)
          max_memory_in_mb    = optional(number)
          max_percentage_cpu  = optional(number)
        }))
        linux_fx_version                 = optional(string)
        load_balancing_mode              = optional(string, "LeastRequests")
        local_mysql_enabled              = optional(bool, false)
        logs_directory_size_limit        = optional(number)
        managed_pipeline_mode            = optional(string, "Integrated")
        min_tls_cipher_suite             = optional(string)
        minimum_tls_version              = optional(string, "1.3")
        node_version                     = optional(string)
        php_version                      = optional(string)
        powershell_version               = optional(string)
        pre_warmed_instance_count        = optional(number)
        python_version                   = optional(string)
        remote_debugging_enabled         = optional(bool, false)
        remote_debugging_version         = optional(string)
        request_tracing_enabled          = optional(bool)
        request_tracing_expiration_time  = optional(string)
        runtime_scale_monitoring_enabled = optional(bool)
        scm_ip_restriction = optional(list(object({
          action                    = optional(string, "Allow")
          ip_address                = optional(string)
          name                      = optional(string)
          priority                  = optional(number, 65000)
          service_tag               = optional(string)
          virtual_network_subnet_id = optional(string)
          headers = optional(object({
            x_azure_fdid      = optional(list(string))
            x_fd_health_probe = optional(list(string))
            x_forwarded_for   = optional(list(string))
            x_forwarded_host  = optional(list(string))
          }))
        })), [])
        scm_ip_restriction_default_action      = optional(string, "Allow")
        scm_minimum_tls_version                = optional(string, "1.2")
        scm_type                               = optional(string, "None")
        scm_use_main_ip_restriction            = optional(bool, false)
        tracing_options                        = optional(string)
        use_32_bit_worker                      = optional(bool, false)
        vnet_private_ports_count               = optional(number)
        vnet_route_all_enabled                 = optional(bool, false)
        website_time_zone                      = optional(string)
        websockets_enabled                     = optional(bool, false)
        windows_fx_version                     = optional(string)
        worker_count                           = optional(number)
        application_insights_connection_string = optional(string)
        application_insights_key               = optional(string)
        application_stack = optional(object({
          docker = optional(object({
            docker_image_name   = optional(string)
            docker_registry_url = optional(string)
            docker_image_tag    = optional(string, "latest")
          }))
          dotnet = optional(object({
            dotnet_version              = optional(string)
            current_stack               = optional(string)
            use_custom_runtime          = optional(bool, false)
            use_dotnet_isolated_runtime = optional(bool, false)
          }))
          java = optional(object({
            java_version           = optional(string)
            java_container         = optional(string)
            java_container_version = optional(string)
          }))
          node = optional(object({
            node_version = optional(string)
          }))
          php = optional(object({
            php_version = optional(string)
          }))
          python = optional(object({
            python_version = optional(string)
          }))
          powershell = optional(object({
            powershell_version = optional(string)
          }))
        }))
        virtual_application = optional(list(object({
          physical_path   = optional(string, "site\\wwwroot")
          preload_enabled = optional(bool, false)
          virtual_path    = optional(string, "/")
          virtual_directory = optional(list(object({
            physical_path = optional(string)
            virtual_path  = optional(string)
          })), [])
        })), [])
      }), {})
      lock = optional(object({
        kind = string
        name = optional(string, null)
      }), null)
      private_endpoints = optional(map(object({
        name = optional(string, null)
        role_assignments = optional(map(object({
          role_definition_id_or_name             = string
          principal_id                           = string
          description                            = optional(string, null)
          skip_service_principal_aad_check       = optional(bool, false)
          condition                              = optional(string, null)
          condition_version                      = optional(string, null)
          delegated_managed_identity_resource_id = optional(string, null)
          principal_type                         = optional(string, null)
        })), {})
        lock = optional(object({
          kind = string
          name = optional(string, null)
        }), null)
        tags                                    = optional(map(string), null)
        subnet_resource_id                      = string
        private_dns_zone_group_name             = optional(string, "default")
        private_dns_zone_resource_ids           = optional(set(string), [])
        application_security_group_associations = optional(map(string), {})
        private_service_connection_name         = optional(string, null)
        network_interface_name                  = optional(string, null)
        location                                = optional(string, null)
        resource_group_name                     = optional(string, null)
        ip_configurations = optional(map(object({
          name               = string
          private_ip_address = string
          member_name        = optional(string, null)
        })), {})
      })), {})
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
        principal_type                         = optional(string, null)
      })), {})
      storage_shares_to_mount = optional(map(object({
        account_name = string
        mount_path   = string
        name         = string
        share_name   = string
        type         = optional(string, "AzureFiles")
      })), {})
      connection_strings = optional(map(object({
        name  = optional(string)
        type  = optional(string)
        value = optional(string)
      })), {})
    })), {})
    deployment_slots_inherit_lock = optional(bool, true)
    diagnostic_settings = optional(map(object({
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
    })), {})
    dns_configuration = optional(object({
      dns_alt_server            = optional(string)
      dns_max_cache_timeout     = optional(number)
      dns_retry_attempt_count   = optional(number)
      dns_retry_attempt_timeout = optional(number)
      dns_servers               = optional(list(string))
    }), null)
    enabled                                  = optional(bool, true)
    enable_telemetry                         = optional(bool, null)
    end_to_end_encryption_enabled            = optional(bool, null)
    fc1_runtime_name                         = optional(string, null)
    fc1_runtime_version                      = optional(string, null)
    ftp_publish_basic_authentication_enabled = optional(bool, false)
    function_app_uses_fc1                    = optional(bool, false)
    functions_extension_version              = optional(string, "~4")
    host_names_disabled                      = optional(bool, null)
    hosting_environment_id                   = optional(string, null)
    https_only                               = optional(bool, true)
    hyper_v                                  = optional(bool, null)
    instance_memory_in_mb                    = optional(number, 2048)
    ip_mode                                  = optional(string, null)
    key_vault_reference_identity             = optional(string, null)
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    logic_app_runtime_version = optional(string, "~4")
    logs = optional(map(object({
      application_logs = optional(map(object({
        azure_blob_storage = optional(object({
          level             = optional(string, "Off")
          retention_in_days = optional(number, 0)
          sas_url           = string
        }))
        file_system = optional(object({
          level = optional(string, "Off")
        }), {})
      })), {})
      detailed_error_messages = optional(bool, false)
      failed_requests_tracing = optional(bool, false)
      http_logs = optional(map(object({
        azure_blob_storage = optional(object({
          retention_in_days = optional(number, 0)
          sas_url           = string
        }))
        file_system = optional(object({
          retention_in_days = optional(number, 0)
          retention_in_mb   = number
        }))
      })), {})
    })), {})
    managed_environment_id = optional(string, null)
    managed_identities = optional(object({
      system_assigned            = optional(bool, false)
      user_assigned_resource_ids = optional(set(string), [])
    }), {})
    maximum_instance_count = optional(number, null)
    private_endpoints = optional(map(object({
      name = optional(string, null)
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
        principal_type                         = optional(string, null)
      })), {})
      lock = optional(object({
        kind = string
        name = optional(string, null)
      }), null)
      tags                                    = optional(map(string), null)
      subnet_resource_id                      = string
      private_dns_zone_group_name             = optional(string, "default")
      private_dns_zone_resource_ids           = optional(set(string), [])
      application_security_group_associations = optional(map(string), {})
      private_service_connection_name         = optional(string, null)
      network_interface_name                  = optional(string, null)
      location                                = optional(string, null)
      resource_group_name                     = optional(string, null)
      ip_configurations = optional(map(object({
        name               = string
        private_ip_address = string
        member_name        = optional(string, null)
      })), {})
    })), null)
    private_endpoints_inherit_lock          = optional(bool, true)
    private_endpoints_manage_dns_zone_group = optional(bool, true)
    public_network_access_enabled           = optional(bool, false)
    redundancy_mode                         = optional(string, null)
    resource_config = optional(object({
      cpu    = optional(number)
      memory = optional(string)
    }), null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    scm_publish_basic_authentication_enabled = optional(bool, true)
    scm_site_also_stopped                    = optional(bool, null)
    site_config = optional(object({
      always_on             = optional(bool, true)
      api_definition_url    = optional(string)
      api_management_api_id = optional(string)
      app_command_line      = optional(string)
      app_scale_limit       = optional(number)
      auto_heal_enabled     = optional(bool)
      auto_heal_rules = optional(object({
        actions = optional(object({
          action_type = string
          custom_action = optional(object({
            exe        = string
            parameters = optional(string)
          }))
          min_process_execution_time = optional(string, "00:00:00")
        }))
        triggers = optional(object({
          private_bytes_in_kb = optional(number)
          requests = optional(object({
            count         = number
            time_interval = string
          }))
          slow_requests = optional(object({
            count         = number
            time_interval = string
            time_taken    = string
            path          = optional(string)
          }))
          slow_requests_with_path = optional(list(object({
            count         = number
            time_interval = string
            time_taken    = string
            path          = optional(string)
          })), [])
          status_codes = optional(list(object({
            count         = number
            time_interval = string
            status        = number
            path          = optional(string)
            sub_status    = optional(number)
            win32_status  = optional(number)
          })), [])
          status_codes_range = optional(list(object({
            count         = number
            time_interval = string
            status_codes  = string
            path          = optional(string)
          })), [])
        }))
      }))
      auto_swap_slot_name                           = optional(string)
      container_registry_managed_identity_client_id = optional(string)
      container_registry_use_managed_identity       = optional(bool)
      cors = optional(object({
        allowed_origins     = optional(list(string))
        support_credentials = optional(bool, false)
      }))
      default_documents              = optional(list(string))
      detailed_error_logging_enabled = optional(bool)
      document_root                  = optional(string)
      dotnet_framework_version       = optional(string, "v4.0")
      elastic_instance_minimum       = optional(number)
      elastic_web_app_scale_limit    = optional(number)
      experiments = optional(object({
        ramp_up_rules = optional(list(object({
          action_host_name             = optional(string)
          change_decision_callback_url = optional(string)
          change_interval_in_minutes   = optional(number)
          change_step                  = optional(number)
          max_reroute_percentage       = optional(number)
          min_reroute_percentage       = optional(number)
          name                         = optional(string)
          reroute_percentage           = optional(number)
        })), [])
      }))
      ftps_state = optional(string, "FtpsOnly")
      handler_mappings = optional(list(object({
        arguments        = optional(string)
        extension        = optional(string)
        script_processor = optional(string)
      })))
      health_check_path    = optional(string)
      http2_enabled        = optional(bool, false)
      http20_proxy_flag    = optional(number)
      http_logging_enabled = optional(bool)
      ip_restriction = optional(list(object({
        action                    = optional(string, "Allow")
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number, 65000)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        headers = optional(object({
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(list(string))
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
        }))
      })), [])
      ip_restriction_default_action = optional(string, "Allow")
      java_container                = optional(string)
      java_container_version        = optional(string)
      java_version                  = optional(string)
      limits = optional(object({
        max_disk_size_in_mb = optional(number)
        max_memory_in_mb    = optional(number)
        max_percentage_cpu  = optional(number)
      }))
      linux_fx_version                 = optional(string)
      load_balancing_mode              = optional(string, "LeastRequests")
      local_mysql_enabled              = optional(bool, false)
      logs_directory_size_limit        = optional(number)
      managed_pipeline_mode            = optional(string, "Integrated")
      min_tls_cipher_suite             = optional(string)
      minimum_tls_version              = optional(string, "1.3")
      node_version                     = optional(string)
      php_version                      = optional(string)
      powershell_version               = optional(string)
      pre_warmed_instance_count        = optional(number)
      python_version                   = optional(string)
      remote_debugging_enabled         = optional(bool, false)
      remote_debugging_version         = optional(string)
      request_tracing_enabled          = optional(bool)
      request_tracing_expiration_time  = optional(string)
      runtime_scale_monitoring_enabled = optional(bool)
      scm_ip_restriction = optional(list(object({
        action                    = optional(string, "Allow")
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number, 65000)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        headers = optional(object({
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(list(string))
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
        }))
      })), [])
      scm_ip_restriction_default_action      = optional(string, "Allow")
      scm_minimum_tls_version                = optional(string, "1.2")
      scm_type                               = optional(string, "None")
      scm_use_main_ip_restriction            = optional(bool, false)
      tracing_options                        = optional(string)
      use_32_bit_worker                      = optional(bool, false)
      vnet_private_ports_count               = optional(number)
      vnet_route_all_enabled                 = optional(bool, false)
      website_time_zone                      = optional(string)
      websockets_enabled                     = optional(bool, false)
      windows_fx_version                     = optional(string)
      worker_count                           = optional(number)
      application_insights_connection_string = optional(string)
      application_insights_key               = optional(string)
      application_stack = optional(object({
        docker = optional(object({
          docker_image_name   = optional(string)
          docker_registry_url = optional(string)
          docker_image_tag    = optional(string, "latest")
        }))
        dotnet = optional(object({
          dotnet_version              = optional(string)
          current_stack               = optional(string)
          use_custom_runtime          = optional(bool, false)
          use_dotnet_isolated_runtime = optional(bool, false)
        }))
        java = optional(object({
          java_version           = optional(string)
          java_container         = optional(string)
          java_container_version = optional(string)
        }))
        node = optional(object({
          node_version = optional(string)
        }))
        php = optional(object({
          php_version = optional(string)
        }))
        python = optional(object({
          python_version = optional(string)
        }))
        powershell = optional(object({
          powershell_version = optional(string)
        }))
      }))
      virtual_application = optional(list(object({
        physical_path   = optional(string, "site\\wwwroot")
        preload_enabled = optional(bool, false)
        virtual_path    = optional(string, "/")
        virtual_directory = optional(list(object({
          physical_path = optional(string)
          virtual_path  = optional(string)
        })), [])
      })), [])
    }), {})
    ssh_enabled = optional(bool, null)
    sticky_settings = optional(map(object({
      app_setting_names       = optional(list(string))
      connection_string_names = optional(list(string))
    })), {})
    storage_account_access_key  = optional(string, null)
    storage_account_name        = optional(string, null)
    storage_account_required    = optional(bool, null)
    storage_account_share_name  = optional(string, null)
    storage_authentication_type = optional(string, null)
    storage_container_endpoint  = optional(string, null)
    storage_container_type      = optional(string, null)
    storage_shares_to_mount = optional(map(object({
      access_key   = string
      account_name = string
      mount_path   = string
      name         = string
      share_name   = string
      type         = optional(string, "AzureFiles")
    })), {})
    storage_user_assigned_identity_id = optional(string, null)
    storage_uses_managed_identity     = optional(bool, false)
    tags                              = optional(map(string), null)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }), null)
    use_extension_bundle                   = optional(bool, true)
    virtual_network_backup_restore_enabled = optional(bool, false)
    virtual_network_subnet_id              = optional(string, null)
    vnet_application_traffic_enabled       = optional(bool, false)
    vnet_content_share_enabled             = optional(bool, null)
    vnet_image_pull_enabled                = optional(bool, null)
    vnet_route_all_traffic                 = optional(bool, false)
    workload_profile_name                  = optional(string, null)
    zip_deploy_file                        = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of web apps to create on the App Service Plan. The map key is used as a unique identifier.

- `name` - (Required) The name of the web app.
- `kind` - (Optional) The kind of web app. Possible values are 'webapp', 'functionapp', or 'logicapp'. Defaults to 'webapp'.
- `os_type` - (Optional) The OS type for the web app. Defaults to the App Service Plan's OS type.
- `all_child_resources_inherit_tags` - (Optional) Should child resources inherit tags? Defaults to true.
- `always_ready` - (Optional) A map of always-ready instances for Flex Consumption Function Apps.
- `app_service_active_slot` - (Optional) Object that sets the active slot for the App Service.
- `app_settings` - (Optional) A map of app settings key-value pairs.
- `application_insights_connection_string` - (Optional) The Application Insights connection string.
- `application_insights_key` - (Optional) The Application Insights instrumentation key.
- `auth_settings` - (Optional) Authentication settings for the web app.
- `auth_settings_v2` - (Optional) Authentication settings V2 for the web app.
- `auto_generated_domain_name_label_scope` - (Optional) Scope of the auto-generated domain name label.
- `backup` - (Optional) Backup configuration for the web app.
- `builtin_logging_enabled` - (Optional) Should builtin logging be enabled? Defaults to true.
- `bundle_version` - (Optional) The extension bundle version (Logic App). Defaults to '[1.*, 2.0.0)'.
- `client_affinity_enabled` - (Optional) Should client affinity be enabled? Defaults to false.
- `client_affinity_partitioning_enabled` - (Optional) Should client affinity partitioning be enabled?
- `client_affinity_proxy_enabled` - (Optional) Should client affinity proxy be enabled?
- `client_certificate_enabled` - (Optional) Should client certificates be enabled? Defaults to false.
- `client_certificate_exclusion_paths` - (Optional) Client certificate exclusion paths.
- `client_certificate_mode` - (Optional) Client certificate mode. Defaults to 'Required'.
- `connection_strings` - (Optional) A map of connection strings.
- `container_size` - (Optional) The function container size in MB.
- `content_share_force_disabled` - (Optional) Should content share be force disabled? Defaults to false.
- `custom_domains` - (Optional) A map of custom domains.
- `daily_memory_time_quota` - (Optional) Daily memory time quota in GB-seconds. Defaults to 0.
- `dapr_config` - (Optional) Dapr configuration for Container Apps environments.
- `deployment_slots` - (Optional) A map of deployment slots.
- `deployment_slots_inherit_lock` - (Optional) Should slots inherit the parent lock? Defaults to true.
- `diagnostic_settings` - (Optional) Diagnostic settings for the web app.
- `dns_configuration` - (Optional) DNS configuration for the web app.
- `enabled` - (Optional) Is the web app enabled? Defaults to true.
- `enable_telemetry` - (Optional) Override the module-level telemetry setting.
- `end_to_end_encryption_enabled` - (Optional) Should end-to-end encryption be enabled?
- `fc1_runtime_name` - (Optional) The Flex Consumption runtime name.
- `fc1_runtime_version` - (Optional) The Flex Consumption runtime version.
- `ftp_publish_basic_authentication_enabled` - (Optional) Should FTP basic auth be enabled? Defaults to false.
- `function_app_uses_fc1` - (Optional) Should this use Flex Consumption? Defaults to false.
- `functions_extension_version` - (Optional) The Azure Functions runtime version. Defaults to '~4'.
- `host_names_disabled` - (Optional) Should public hostnames be disabled?
- `hosting_environment_id` - (Optional) The App Service Environment resource ID.
- `https_only` - (Optional) Should the app only be accessible over HTTPS? Defaults to true.
- `hyper_v` - (Optional) Should the app run in Hyper-V isolation?
- `instance_memory_in_mb` - (Optional) Memory for Flex Consumption instances. Defaults to 2048.
- `ip_mode` - (Optional) The IP mode (IPv4, IPv4AndIPv6, IPv6).
- `key_vault_reference_identity` - (Optional) The identity for Key Vault references.
- `lock` - (Optional) Lock configuration for the web app.
- `logic_app_runtime_version` - (Optional) The Logic App runtime version. Defaults to '~4'.
- `logs` - (Optional) Logs configuration for the web app.
- `managed_environment_id` - (Optional) The Container Apps managed environment ID.
- `managed_identities` - (Optional) Managed identity configuration.
- `maximum_instance_count` - (Optional) Maximum scale-out instance count.
- `private_endpoints` - (Optional) A map of private endpoints. Defaults to null (uses computed value).
- `private_endpoints_inherit_lock` - (Optional) Should private endpoints inherit lock? Defaults to true.
- `private_endpoints_manage_dns_zone_group` - (Optional) Should this module manage DNS zone groups? Defaults to true.
- `public_network_access_enabled` - (Optional) Should public network access be enabled? Defaults to false.
- `redundancy_mode` - (Optional) The site redundancy mode.
- `resource_config` - (Optional) Resource config for Container App environments.
- `role_assignments` - (Optional) Role assignments for the web app.
- `scm_publish_basic_authentication_enabled` - (Optional) Should SCM basic auth be enabled? Defaults to true.
- `scm_site_also_stopped` - (Optional) Should SCM site also be stopped?
- `site_config` - (Optional) The site configuration block with explicit type definition.
- `ssh_enabled` - (Optional) Should SSH be enabled?
- `sticky_settings` - (Optional) Sticky settings for slot swaps.
- `storage_account_access_key` - (Optional) The Storage Account access key (Function App).
- `storage_account_name` - (Optional) The Storage Account name (Function App).
- `storage_account_required` - (Optional) Should a storage account be required?
- `storage_account_share_name` - (Optional) The storage account file share name (Logic App).
- `storage_authentication_type` - (Optional) The storage authentication type.
- `storage_container_endpoint` - (Optional) The storage container endpoint (Flex Consumption).
- `storage_container_type` - (Optional) The storage container type.
- `storage_shares_to_mount` - (Optional) A map of storage shares to mount.
- `storage_user_assigned_identity_id` - (Optional) The user-assigned identity ID for storage.
- `storage_uses_managed_identity` - (Optional) Should storage use managed identity? Defaults to false.
- `tags` - (Optional) Additional tags, merged with module-level tags.
- `timeouts` - (Optional) Timeout configuration for CRUD operations.
- `use_extension_bundle` - (Optional) Should the extension bundle be used? Defaults to true.
- `virtual_network_backup_restore_enabled` - (Optional) Should backup/restore use VNet? Defaults to false.
- `virtual_network_subnet_id` - (Optional) The subnet ID for VNet integration. Defaults to null (uses computed value).
- `vnet_application_traffic_enabled` - (Optional) Should app traffic use VNet? Defaults to false.
- `vnet_content_share_enabled` - (Optional) Should content share use VNet? Defaults to null (uses computed value).
- `vnet_image_pull_enabled` - (Optional) Should image pull use VNet? Defaults to null (uses computed value).
- `vnet_route_all_traffic` - (Optional) Should all outbound traffic use VNet? Defaults to false.
- `workload_profile_name` - (Optional) The workload profile name for Container Apps.
- `zip_deploy_file` - (Optional) The path to the zip file to deploy.
DESCRIPTION
  nullable    = false
}
