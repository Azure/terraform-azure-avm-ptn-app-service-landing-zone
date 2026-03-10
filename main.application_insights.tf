module "application_insights" {
  source  = "Azure/avm-res-insights-component/azurerm"
  version = "0.3.0"
  count   = var.application_insights_enabled && var.application_insights_resource_id == null ? 1 : 0

  location                              = var.location
  name                                  = coalesce(var.application_insights_name, "ai-${var.name}")
  resource_group_name                   = var.resource_group_name
  workspace_id                          = var.log_analytics_workspace_resource_id
  application_type                      = var.application_insights_application_type
  daily_data_cap_in_gb                  = var.application_insights_daily_data_cap_in_gb
  daily_data_cap_notifications_disabled = var.application_insights_daily_data_cap_notifications_disabled
  disable_ip_masking                    = var.application_insights_disable_ip_masking
  enable_telemetry                      = var.enable_telemetry
  force_customer_storage_for_profiler   = var.application_insights_force_customer_storage_for_profiler
  internet_ingestion_enabled            = var.application_insights_internet_ingestion_enabled
  internet_query_enabled                = var.application_insights_internet_query_enabled
  linked_storage_account                = var.application_insights_linked_storage_account
  local_authentication_disabled         = var.application_insights_local_authentication_disabled
  lock                                  = var.application_insights_lock
  retention_in_days                     = var.application_insights_retention_in_days
  role_assignments                      = var.application_insights_role_assignments
  sampling_percentage                   = var.application_insights_sampling_percentage
  tags                                  = coalesce(var.application_insights_tags, var.tags)
}
