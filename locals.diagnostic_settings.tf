locals {
  # Diagnostic settings locals handle three concerns:
  # 1. Auto-enable: When log_analytics_workspace_resource_id is provided and the user hasn't
  #    supplied custom settings, generate a default diagnostic setting with allLogs + AllMetrics.
  # 2. LAW defaulting: When the user provides custom settings without a workspace_resource_id,
  #    fall back to var.log_analytics_workspace_resource_id.
  # 3. Interface coercion: Modules using the old interface (log_categories/log_groups/metric_categories)
  #    receive coerced values from the new logs/metrics object interface.
  #
  # The ALZ diagnostic settings mode conditional (which passes {} to skip diagnostic settings
  # entirely) is handled in the main.*.tf files, not here.

  # --- Shared defaults ---

  _diag_default_old = var.log_analytics_workspace_resource_id != null ? {
    default = {
      name                                     = null
      log_categories                           = toset([])
      log_groups                               = toset(["allLogs"])
      metric_categories                        = toset(["AllMetrics"])
      log_analytics_destination_type           = "Dedicated"
      workspace_resource_id                    = var.log_analytics_workspace_resource_id
      storage_account_resource_id              = null
      event_hub_authorization_rule_resource_id = null
      event_hub_name                           = null
      marketplace_partner_resource_id          = null
    }
  } : {}

  _diag_default_old_metrics_only = var.log_analytics_workspace_resource_id != null ? {
    default = {
      name                                     = null
      metric_categories                        = toset(["AllMetrics"])
      log_analytics_destination_type           = "Dedicated"
      workspace_resource_id                    = var.log_analytics_workspace_resource_id
      storage_account_resource_id              = null
      event_hub_authorization_rule_resource_id = null
      event_hub_name                           = null
      marketplace_partner_resource_id          = null
    }
  } : {}

  _diag_default_new = var.log_analytics_workspace_resource_id != null ? {
    default = {
      name = null
      logs = toset([{
        category       = null
        category_group = "allLogs"
        enabled        = true
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
      workspace_resource_id                    = var.log_analytics_workspace_resource_id
      storage_account_resource_id              = null
      event_hub_authorization_rule_resource_id = null
      event_hub_name                           = null
      marketplace_partner_resource_id          = null
    }
  } : {}

  # --- Helper: coerce new interface → old interface for a single entry ---

  _coerce_old = {
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
        workspace_resource_id                    = dv.workspace_resource_id != null ? dv.workspace_resource_id : var.log_analytics_workspace_resource_id
        storage_account_resource_id              = dv.storage_account_resource_id
        event_hub_authorization_rule_resource_id = dv.event_hub_authorization_rule_resource_id
        event_hub_name                           = dv.event_hub_name
        marketplace_partner_resource_id          = dv.marketplace_partner_resource_id
      }
    }
  }

  # --- Modules using OLD interface ---
  # When the user supplies settings, coerce + LAW-default. When empty, auto-enable if LAW is provided.

  application_gateway_diagnostic_settings = length(var.application_gateway_diagnostic_settings) > 0 ? local._coerce_old["application_gateway"] : local._diag_default_old
  bastion_host_diagnostic_settings        = length(var.bastion_host_diagnostic_settings) > 0 ? local._coerce_old["bastion_host"] : local._diag_default_old
  container_registry_diagnostic_settings  = length(var.container_registry_diagnostic_settings) > 0 ? local._coerce_old["container_registry"] : local._diag_default_old
  front_door_diagnostic_settings          = length(var.front_door_diagnostic_settings) > 0 ? local._coerce_old["front_door"] : local._diag_default_old
  key_vault_diagnostic_settings           = length(var.key_vault_diagnostic_settings) > 0 ? local._coerce_old["key_vault"] : local._diag_default_old
  virtual_network_diagnostic_settings     = length(var.virtual_network_diagnostic_settings) > 0 ? local._coerce_old["virtual_network"] : local._diag_default_old

  # --- Storage account (OLD interface, multiple sub-services) ---

  storage_account_diagnostic_settings = length(var.storage_account_diagnostic_settings) > 0 ? {
    for k, v in var.storage_account_diagnostic_settings : k => {
      name = v.name
      metric_categories = toset([
        for m in v.metrics : m.category if m.category != null && m.enabled
      ])
      log_analytics_destination_type           = v.log_analytics_destination_type
      workspace_resource_id                    = v.workspace_resource_id != null ? v.workspace_resource_id : var.log_analytics_workspace_resource_id
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  } : local._diag_default_old_metrics_only

  _storage_sub_vars = {
    "blob"  = var.storage_account_diagnostic_settings_blob,
    "file"  = var.storage_account_diagnostic_settings_file,
    "queue" = var.storage_account_diagnostic_settings_queue,
    "table" = var.storage_account_diagnostic_settings_table,
  }

  _storage_sub_coerced = {
    for sub_key, sub_var in local._storage_sub_vars : sub_key => {
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
        workspace_resource_id                    = v.workspace_resource_id != null ? v.workspace_resource_id : var.log_analytics_workspace_resource_id
        storage_account_resource_id              = v.storage_account_resource_id
        event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
        event_hub_name                           = v.event_hub_name
        marketplace_partner_resource_id          = v.marketplace_partner_resource_id
      }
    }
  }

  storage_account_diagnostic_settings_blob  = length(var.storage_account_diagnostic_settings_blob) > 0 ? local._storage_sub_coerced["blob"] : local._diag_default_old
  storage_account_diagnostic_settings_file  = length(var.storage_account_diagnostic_settings_file) > 0 ? local._storage_sub_coerced["file"] : local._diag_default_old
  storage_account_diagnostic_settings_queue = length(var.storage_account_diagnostic_settings_queue) > 0 ? local._storage_sub_coerced["queue"] : local._diag_default_old
  storage_account_diagnostic_settings_table = length(var.storage_account_diagnostic_settings_table) > 0 ? local._storage_sub_coerced["table"] : local._diag_default_old

  # --- Modules using NEW interface (logs / metrics objects) ---
  # When the user supplies settings, LAW-default only. When empty, auto-enable if LAW is provided.

  _new_law_default = {
    for resource_key, resource_var in {
      "app_service_environment" = var.app_service_environment_diagnostic_settings,
      "app_service_plan"        = var.app_service_plan_diagnostic_settings,
    } : resource_key => {
      for k, v in resource_var : k => merge(v, {
        workspace_resource_id = v.workspace_resource_id != null ? v.workspace_resource_id : var.log_analytics_workspace_resource_id
      })
    }
  }

  app_service_environment_diagnostic_settings = length(var.app_service_environment_diagnostic_settings) > 0 ? local._new_law_default["app_service_environment"] : local._diag_default_new
  app_service_plan_diagnostic_settings        = length(var.app_service_plan_diagnostic_settings) > 0 ? local._new_law_default["app_service_plan"] : local._diag_default_new

  # --- Web apps (NEW interface, per-app settings) ---
  # Each web app gets its own diagnostic settings. When a web app's settings are empty, auto-enable.

  web_app_diagnostic_settings = {
    for app_key, app in var.web_apps : app_key => (
      length(app.diagnostic_settings) > 0 ? {
        for k, v in app.diagnostic_settings : k => merge(v, {
          workspace_resource_id = v.workspace_resource_id != null ? v.workspace_resource_id : var.log_analytics_workspace_resource_id
        })
      } : local._diag_default_new
    )
  }
}
