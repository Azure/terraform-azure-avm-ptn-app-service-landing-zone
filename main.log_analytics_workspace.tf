module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"
  count   = local.log_analytics_workspace_creation_enabled ? 1 : 0

  location            = var.location
  name                = coalesce(var.log_analytics_workspace_name, module.naming.resource_names.log_analytics_workspace)
  resource_group_name = local.resource_group_name
  enable_telemetry    = var.enable_telemetry
  tags                = var.tags

  log_analytics_workspace_internet_ingestion_enabled     = local.virtual_network_enabled ? "false" : "true"
  monitor_private_link_scoped_service_name               = module.naming.resource_names.ampls_law_scoped_service
  log_analytics_workspace_internet_query_enabled     = local.virtual_network_enabled ? "false" : "true"

  monitor_private_link_scope = local.virtual_network_enabled ? {
    default = {
      name                  = coalesce(var.log_analytics_workspace_name, module.naming.resource_names.azure_monitor_private_link_scope)
      resource_id           = local.resource_group_id
      ingestion_access_mode = "PrivateOnly"
      query_access_mode     = "Open"
    }
  } : {}

  private_endpoints = local.virtual_network_enabled ? {
    default = {
      subnet_resource_id            = local.private_endpoint_subnet_id
      private_dns_zone_resource_ids = local.log_analytics_workspace_private_dns_zone_resource_ids
    }
  } : {}

  private_endpoint_extensions = local.virtual_network_enabled ? {
    default = {
      monitor_private_link_scope_key = "default"
    }
  } : {}
}

# Link Application Insights to the AMPLS created by the LAW module
resource "azurerm_monitor_private_link_scoped_service" "application_insights" {
  count = local.log_analytics_workspace_creation_enabled && local.virtual_network_enabled && var.application_insights_enabled ? 1 : 0

  name                = module.naming.resource_names.ampls_appinsights_scoped_service
  resource_group_name = local.resource_group_name
  scope_name          = coalesce(var.log_analytics_workspace_name, module.naming.resource_names.azure_monitor_private_link_scope)
  linked_resource_id  = module.application_insights[0].resource_id

  depends_on = [module.log_analytics_workspace]
}
