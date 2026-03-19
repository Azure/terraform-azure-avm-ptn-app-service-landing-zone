locals {
  app_service_environment_diagnostic_settings = length(var.app_service_environment_diagnostic_settings) > 0 ? local.diag_new_law_default["app_service_environment"] : local.diag_default_new
  app_service_plan_diagnostic_settings        = length(var.app_service_plan_diagnostic_settings) > 0 ? local.diag_new_law_default["app_service_plan"] : local.diag_default_new_metrics_only
  application_gateway_diagnostic_settings     = length(var.application_gateway_diagnostic_settings) > 0 ? local.diag_coerce_old["application_gateway"] : local.diag_default_old
  bastion_host_diagnostic_settings            = length(var.bastion_host_diagnostic_settings) > 0 ? local.diag_coerce_old["bastion_host"] : local.diag_default_old
  container_registry_diagnostic_settings      = length(var.container_registry_diagnostic_settings) > 0 ? local.diag_coerce_old["container_registry"] : local.diag_default_old
  diag_coerce_old = {
    for k, v in {
      "application_gateway" = var.application_gateway_diagnostic_settings,
      "bastion_host"        = var.bastion_host_diagnostic_settings,
      "container_registry"  = var.container_registry_diagnostic_settings,
      "front_door"          = var.front_door_diagnostic_settings,
      "key_vault"           = var.key_vault_diagnostic_settings,
      "virtual_network"     = var.virtual_network_diagnostic_settings,
      } : k => {
      for dk, dv in v : dk => {
        name = dv.name
        log_categories = toset([
          for l in dv.logs : l.category if l.category != null && l.enabled
        ])
        log_groups = toset([
          for l in dv.logs : l.category_group if l.category_group != null && l.enabled
        ])
        metric_categories = toset([
          for m in dv.metrics : m.category if m.category != null && m.enabled
        ])
        log_analytics_destination_type           = dv.log_analytics_destination_type
        workspace_resource_id                    = dv.workspace_resource_id != null ? dv.workspace_resource_id : local.log_analytics_workspace_resource_id
        storage_account_resource_id              = dv.storage_account_resource_id
        event_hub_authorization_rule_resource_id = dv.event_hub_authorization_rule_resource_id
        event_hub_name                           = dv.event_hub_name
        marketplace_partner_resource_id          = dv.marketplace_partner_resource_id
      }
    }
  }
  diag_default_new = var.default_diagnostic_settings_enabled ? {
    default = {
      name = "default-diagnostic-setting"
      logs = toset([{
        category       = null
        category_group = "allLogs"
        enabled        = true
        retention_policy = {
          days    = 0
          enabled = false
        }
        }, {
        category       = null
        category_group = "audit"
        enabled        = false
        retention_policy = {
          days    = 0
          enabled = false
        }
      }])
      metrics = toset([{
        category = "AllMetrics"
        enabled  = true
        retention_policy = {
          days    = 0
          enabled = false
        }
      }])
      log_analytics_destination_type           = "Dedicated"
      workspace_resource_id                    = local.log_analytics_workspace_resource_id
      storage_account_resource_id              = null
      event_hub_authorization_rule_resource_id = null
      event_hub_name                           = null
      marketplace_partner_resource_id          = null
    }
  } : {}
  diag_default_new_metrics_only = var.default_diagnostic_settings_enabled ? {
    default = {
      name = "default-diagnostic-setting"
      logs = toset([])
      metrics = toset([{
        category = "AllMetrics"
        enabled  = true
        retention_policy = {
          days    = 0
          enabled = false
        }
      }])
      log_analytics_destination_type           = "Dedicated"
      workspace_resource_id                    = local.log_analytics_workspace_resource_id
      storage_account_resource_id              = null
      event_hub_authorization_rule_resource_id = null
      event_hub_name                           = null
      marketplace_partner_resource_id          = null
    }
  } : {}
  diag_default_old = var.default_diagnostic_settings_enabled ? {
    default = {
      name                                     = "default-diagnostic-setting"
      log_categories                           = toset([])
      log_groups                               = toset(["allLogs"])
      metric_categories                        = toset(["AllMetrics"])
      log_analytics_destination_type           = "Dedicated"
      workspace_resource_id                    = local.log_analytics_workspace_resource_id
      storage_account_resource_id              = null
      event_hub_authorization_rule_resource_id = null
      event_hub_name                           = null
      marketplace_partner_resource_id          = null
    }
  } : {}
  diag_default_old_metrics_only = var.default_diagnostic_settings_enabled ? {
    default = {
      name                                     = "default-diagnostic-setting"
      metric_categories                        = toset(["Transaction"])
      log_analytics_destination_type           = "Dedicated"
      workspace_resource_id                    = local.log_analytics_workspace_resource_id
      storage_account_resource_id              = null
      event_hub_authorization_rule_resource_id = null
      event_hub_name                           = null
      marketplace_partner_resource_id          = null
    }
  } : {}
  diag_default_old_storage_sub = var.default_diagnostic_settings_enabled ? {
    default = {
      name                                     = "default-diagnostic-setting"
      log_categories                           = toset([])
      log_groups                               = toset(["allLogs"])
      metric_categories                        = toset(["Capacity", "Transaction"])
      log_analytics_destination_type           = "Dedicated"
      workspace_resource_id                    = local.log_analytics_workspace_resource_id
      storage_account_resource_id              = null
      event_hub_authorization_rule_resource_id = null
      event_hub_name                           = null
      marketplace_partner_resource_id          = null
    }
  } : {}
  diag_new_law_default = {
    for resource_key, resource_var in {
      "app_service_environment" = var.app_service_environment_diagnostic_settings,
      "app_service_plan"        = var.app_service_plan_diagnostic_settings,
      } : resource_key => {
      for k, v in resource_var : k => merge(v, {
        workspace_resource_id = v.workspace_resource_id != null ? v.workspace_resource_id : local.log_analytics_workspace_resource_id
      })
    }
  }
  diag_storage_sub_coerced = {
    for sub_key, sub_var in local.diag_storage_sub_vars : sub_key => {
      for k, v in sub_var : k => {
        name = v.name
        log_categories = toset([
          for l in v.logs : l.category if l.category != null && l.enabled
        ])
        log_groups = toset([
          for l in v.logs : l.category_group if l.category_group != null && l.enabled
        ])
        metric_categories = toset([
          for m in v.metrics : m.category if m.category != null && m.enabled
        ])
        log_analytics_destination_type           = v.log_analytics_destination_type
        workspace_resource_id                    = v.workspace_resource_id != null ? v.workspace_resource_id : local.log_analytics_workspace_resource_id
        storage_account_resource_id              = v.storage_account_resource_id
        event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
        event_hub_name                           = v.event_hub_name
        marketplace_partner_resource_id          = v.marketplace_partner_resource_id
      }
    }
  }
  diag_storage_sub_vars = {
    "blob"  = var.storage_account_diagnostic_settings_blob,
    "file"  = var.storage_account_diagnostic_settings_file,
    "queue" = var.storage_account_diagnostic_settings_queue,
    "table" = var.storage_account_diagnostic_settings_table,
  }
  front_door_diagnostic_settings = length(var.front_door_diagnostic_settings) > 0 ? local.diag_coerce_old["front_door"] : local.diag_default_old
  key_vault_diagnostic_settings  = length(var.key_vault_diagnostic_settings) > 0 ? local.diag_coerce_old["key_vault"] : local.diag_default_old
  storage_account_diagnostic_settings = length(var.storage_account_diagnostic_settings) > 0 ? {
    for k, v in var.storage_account_diagnostic_settings : k => {
      name = v.name
      metric_categories = toset([
        for m in v.metrics : m.category if m.category != null && m.enabled
      ])
      log_analytics_destination_type           = v.log_analytics_destination_type
      workspace_resource_id                    = v.workspace_resource_id != null ? v.workspace_resource_id : local.log_analytics_workspace_resource_id
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  } : local.diag_default_old_metrics_only
  storage_account_diagnostic_settings_blob = length(var.storage_account_diagnostic_settings_blob) > 0 ? local.diag_storage_sub_coerced["blob"] : local.diag_default_old_storage_sub
  storage_account_diagnostic_settings_file = length(var.storage_account_diagnostic_settings_file) > 0 ? local.diag_storage_sub_coerced["file"] : local.diag_default_old_storage_sub
  virtual_network_diagnostic_settings      = length(var.virtual_network_diagnostic_settings) > 0 ? local.diag_coerce_old["virtual_network"] : local.diag_default_old
  web_app_diagnostic_settings = {
    for app_key, app in var.web_apps : app_key => (
      length(app.diagnostic_settings) > 0 ? {
        for k, v in app.diagnostic_settings : k => merge(v, {
          workspace_resource_id = v.workspace_resource_id != null ? v.workspace_resource_id : local.log_analytics_workspace_resource_id
        })
      } : local.diag_default_new
    )
  }
}
