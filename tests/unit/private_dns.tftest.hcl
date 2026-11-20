mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
      tenant_id                = "00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "azurerm" {}

mock_provider "random" {}

mock_provider "time" {}

variables {
  location                            = "eastus"
  parent_id                           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test"
  enable_telemetry                    = false
  app_service_plan_enabled            = false
  app_service_plan_resource_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Web/serverfarms/test"
  default_diagnostic_settings_enabled = false
  front_door_enabled                  = false
  key_vault_enabled                   = true
  storage_account_enabled             = true
  virtual_network_enabled             = true
  private_dns_zones_enabled           = true
  private_endpoint_subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/private"
  storage_account_shares = {
    share = {
      name  = "share"
      quota = 5
    }
  }
}

run "generated_private_dns_zone_groups" {
  command = plan

  variables {
    web_apps = {
      app = {}
    }
  }

  assert {
    condition     = local.create_private_dns_zone_key_vault && local.create_private_dns_zone_storage_blob && local.create_private_dns_zone_storage_file
    error_message = "Key Vault and storage endpoints should use the generated DNS zones."
  }

  assert {
    condition     = issensitive(output.application_insights) && issensitive(output.log_analytics_workspace) && issensitive(output.storage_account)
    error_message = "Outputs containing sensitive child outputs must remain sensitive."
  }
  providers = {
    azapi   = azapi
    azurerm = azurerm
    random  = random
    time    = time
  }
}

run "existing_private_dns_zones" {
  command = plan

  variables {
    application_insights_enabled              = false
    log_analytics_workspace_enabled           = false
    private_dns_zone_key_vault_resource_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
    private_dns_zone_storage_blob_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
    private_dns_zone_storage_file_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"
  }

  assert {
    condition     = !local.create_private_dns_zone_key_vault && !local.create_private_dns_zone_storage_blob && !local.create_private_dns_zone_storage_file
    error_message = "Existing DNS zones should not be recreated."
  }
  providers = {
    azapi   = azapi
    azurerm = azurerm
    random  = random
    time    = time
  }
}

run "private_dns_disabled" {
  command = plan

  variables {
    application_insights_enabled    = false
    log_analytics_workspace_enabled = false
    private_dns_zones_enabled       = false
  }

  assert {
    condition     = !local.create_private_dns_zone_key_vault && !local.create_private_dns_zone_storage_blob && !local.create_private_dns_zone_storage_file
    error_message = "Disabling private DNS should not create Key Vault or storage DNS zones."
  }
  providers = {
    azapi   = azapi
    azurerm = azurerm
    random  = random
    time    = time
  }
}

run "private_dns_with_registry_adapter" {
  command = plan

  variables {
    application_insights_enabled    = false
    key_vault_enabled               = false
    log_analytics_workspace_enabled = false
    managed_instance_registry_adapters = [{
      registry_key = "HKEY_LOCAL_MACHINE/SOFTWARE/Test"
      type         = "String"
      value        = "example"
    }]
  }

  assert {
    condition     = local.managed_instance_key_vault_needed && local.create_private_dns_zone_key_vault
    error_message = "A registry adapter should enable the Key Vault and its private DNS zone."
  }

  assert {
    condition     = issensitive(local.managed_instance_registry_adapter_secrets_value)
    error_message = "Registry adapter secret values must remain sensitive."
  }
  providers = {
    azapi   = azapi
    azurerm = azurerm
    random  = random
    time    = time
  }
}

run "registry_output_is_sensitive" {
  command = plan

  variables {
    application_insights_enabled    = false
    container_registry_enabled      = true
    log_analytics_workspace_enabled = false
  }

  assert {
    condition     = issensitive(output.container_registry)
    error_message = "The registry output contains sensitive child outputs and must remain sensitive."
  }
  providers = {
    azapi   = azapi
    azurerm = azurerm
    random  = random
    time    = time
  }
}
