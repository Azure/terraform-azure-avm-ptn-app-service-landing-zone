variable "web_apps" {
  type = map(object({
    name                          = string
    kind                          = optional(string, "webapp")
    os_type                       = optional(string, null)
    site_config                   = optional(any, {})
    public_network_access_enabled = optional(bool, false)
    managed_identities = optional(object({
      system_assigned            = optional(bool, false)
      user_assigned_resource_ids = optional(set(string), [])
    }), {})
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
    lock = optional(object({
      kind = string
      name = optional(string, null)
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
    tags             = optional(map(string), null)
    enable_telemetry = optional(bool, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of web apps to create on the App Service Plan. The map key is used as a unique identifier.

- `name` - (Required) The name of the web app.
- `kind` - (Optional) The kind of web app. Possible values are 'webapp' or 'functionapp'. Defaults to 'webapp'.
- `os_type` - (Optional) The OS type for the web app. Defaults to the App Service Plan's OS type.
- `site_config` - (Optional) The site configuration block, passed through to the AVM web site module.
- `public_network_access_enabled` - (Optional) Whether public network access is enabled. Defaults to false for security.
- `managed_identities` - (Optional) Managed identity configuration for the web app.
- `diagnostic_settings` - (Optional) Diagnostic settings for the web app.
- `lock` - (Optional) Lock configuration for the web app.
- `role_assignments` - (Optional) Role assignments for the web app.
- `tags` - (Optional) Additional tags for the web app, merged with module-level tags.
- `enable_telemetry` - (Optional) Override the module-level telemetry setting for this web app.
DESCRIPTION
  nullable    = false
}
