mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "azurerm" {}

mock_provider "random" {}

mock_provider "time" {}

variables {
  location                               = "eastus"
  parent_id                              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test"
  enable_telemetry                       = false
  app_service_plan_enabled               = false
  app_service_plan_resource_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Web/serverfarms/test"
  application_gateway_enabled            = true
  application_gateway_name               = "test-gateway"
  application_gateway_subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/gateway"
  application_insights_enabled           = false
  default_diagnostic_settings_enabled    = false
  front_door_enabled                     = false
  log_analytics_workspace_enabled        = false
  virtual_network_enabled                = false
  web_apps = {
    app = { name = "test-app" }
  }
}

run "default_gateway" {
  command = plan

  assert {
    condition     = module.application_gateway[0].name == "test-gateway"
    error_message = "The generated gateway must retain its configured name."
  }
  providers = {
    azapi   = azapi
    azurerm = azurerm
    random  = random
    time    = time
  }
}

run "custom_gateway" {
  command = plan

  variables {
    application_gateway_backend_address_pools = {
      pool = {
        name         = "pool"
        fqdns        = ["app.example.com"]
        ip_addresses = ["10.0.0.4"]
      }

    }
    application_gateway_backend_http_settings = {
      settings = {
        name                                 = "settings"
        port                                 = 443
        protocol                             = "Https"
        probe_name                           = "probe"
        dedicated_backend_connection_enabled = true
        connection_draining = {
          drain_timeout_sec          = 30
          enable_connection_draining = true
        }
      }
    }
    application_gateway_probe_configurations = {
      probe = {
        name                = "probe"
        interval            = 30
        timeout             = 30
        unhealthy_threshold = 3
        protocol            = "Https"
        path                = "/"
        match = {
          status_code = ["200-399"]
        }
      }
    }
    application_gateway_http_listeners = {
      listener = {
        name               = "listener"
        frontend_port_name = "port-80"
        host_name          = "app.example.com"
      }
    }
    application_gateway_request_routing_rules = {
      route = {
        name                       = "route"
        rule_type                  = "Basic"
        http_listener_name         = "listener"
        backend_address_pool_name  = "pool"
        backend_http_settings_name = "settings"
        rewrite_rule_set_name      = "rewrites"
        priority                   = 100
      }
    }
    application_gateway_rewrite_rule_sets = {
      rewrites = {
        name = "rewrites"
        rewrite_rules = {
          rewrite = {
            name          = "rewrite"
            rule_sequence = 1
            url = {
              components   = "path_only"
              path         = "/new"
              query_string = "ignored"
              reroute      = true
            }
          }
        }
      }
    }
  }

  assert {
    condition     = module.application_gateway[0].name == "test-gateway"
    error_message = "Custom gateway inputs must remain valid."
  }
  providers = {
    azapi   = azapi
    azurerm = azurerm
    random  = random
    time    = time
  }
}

run "sensitive_certificate" {
  command = plan

  variables {
    application_gateway_ssl_certificates = {
      certificate = {
        name     = "certificate"
        data     = "example-test-data"
        password = "example-test-password"
      }
    }

  }

  assert {
    condition     = module.application_gateway[0].name == "test-gateway"
    error_message = "Sensitive certificate inputs must remain usable."
  }
  providers = {
    azapi   = azapi
    azurerm = azurerm
    random  = random
    time    = time
  }
}

run "key_vault_certificate" {
  command = plan

  variables {
    application_gateway_ssl_certificates = {
      certificate = {
        name                = "certificate"
        key_vault_secret_id = "https://example.vault.azure.net/secrets/certificate"
      }
    }
  }

  assert {
    condition     = module.application_gateway[0].name == "test-gateway"
    error_message = "Key Vault certificate references must remain usable."
  }
  providers = {
    azapi   = azapi
    azurerm = azurerm
    random  = random
    time    = time
  }
}
