locals {
  # Helper: coerces the new diagnostic_settings interface (logs/metrics objects) to the old interface
  # (log_categories/log_groups/metric_categories sets) expected by older AVM modules, and defaults
  # workspace_resource_id to var.log_analytics_workspace_resource_id when not explicitly set.

  # --- Modules using OLD interface (log_categories / log_groups / metric_categories) ---

  application_gateway_diagnostic_settings = {
    for k, v in var.application_gateway_diagnostic_settings : k => {
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
      workspace_resource_id                    = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  }

  bastion_host_diagnostic_settings = {
    for k, v in var.bastion_host_diagnostic_settings : k => {
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
      workspace_resource_id                    = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  }

  container_registry_diagnostic_settings = {
    for k, v in var.container_registry_diagnostic_settings : k => {
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
      workspace_resource_id                    = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  }

  front_door_diagnostic_settings = {
    for k, v in var.front_door_diagnostic_settings : k => {
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
      workspace_resource_id                    = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  }

  key_vault_diagnostic_settings = {
    for k, v in var.key_vault_diagnostic_settings : k => {
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
      workspace_resource_id                    = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  }

  storage_account_diagnostic_settings = {
    for k, v in var.storage_account_diagnostic_settings : k => {
      name = v.name
      metric_categories = toset([
        for m in v.metrics : m.category if m.category != null && m.enabled
      ])
      log_analytics_destination_type           = v.log_analytics_destination_type
      workspace_resource_id                    = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  }

  storage_account_diagnostic_settings_blob = {
    for k, v in var.storage_account_diagnostic_settings_blob : k => {
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
      workspace_resource_id                    = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  }

  storage_account_diagnostic_settings_file = {
    for k, v in var.storage_account_diagnostic_settings_file : k => {
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
      workspace_resource_id                    = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  }

  storage_account_diagnostic_settings_queue = {
    for k, v in var.storage_account_diagnostic_settings_queue : k => {
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
      workspace_resource_id                    = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  }

  storage_account_diagnostic_settings_table = {
    for k, v in var.storage_account_diagnostic_settings_table : k => {
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
      workspace_resource_id                    = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  }

  virtual_network_diagnostic_settings = {
    for k, v in var.virtual_network_diagnostic_settings : k => {
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
      workspace_resource_id                    = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
    }
  }

  # --- Modules using NEW interface (logs / metrics objects) ---
  # These just need LAW defaulting, no coercion.

  app_service_environment_diagnostic_settings = {
    for k, v in var.app_service_environment_diagnostic_settings : k => merge(v, {
      workspace_resource_id = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
    })
  }

  app_service_plan_diagnostic_settings = {
    for k, v in var.app_service_plan_diagnostic_settings : k => merge(v, {
      workspace_resource_id = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
    })
  }

  web_app_diagnostic_settings = {
    for app_key, app in var.web_apps : app_key => {
      for k, v in app.diagnostic_settings : k => merge(v, {
        workspace_resource_id = coalesce(v.workspace_resource_id, var.log_analytics_workspace_resource_id)
      })
    }
  }
}
