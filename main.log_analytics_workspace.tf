module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"
  count   = local.log_analytics_workspace_creation_enabled ? 1 : 0

  location                                           = var.location
  name                                               = coalesce(var.log_analytics_workspace_name, module.naming.resource_names.log_analytics_workspace)
  resource_group_name                                = local.resource_group_name
  enable_telemetry                                   = var.enable_telemetry
  log_analytics_workspace_internet_ingestion_enabled = local.virtual_network_enabled ? "false" : "true"
  log_analytics_workspace_internet_query_enabled     = var.log_analytics_workspace_internet_query_enabled
  monitor_private_link_scope = local.virtual_network_enabled ? {
    default = {
      name                  = coalesce(var.log_analytics_workspace_name, module.naming.resource_names.azure_monitor_private_link_scope)
      resource_id           = local.resource_group_id
      ingestion_access_mode = "PrivateOnly"
      query_access_mode     = "Open"
    }
  } : {}
  monitor_private_link_scoped_service_name = module.naming.resource_names.ampls_law_scoped_service
  tags                                     = var.tags
}

# Look up the AMPLS created by the LAW module to get its canonical resource ID
data "azapi_resource" "log_analytics_workspace_ampls" {
  count = local.log_analytics_workspace_creation_enabled && local.virtual_network_enabled ? 1 : 0

  name                   = coalesce(var.log_analytics_workspace_name, module.naming.resource_names.azure_monitor_private_link_scope)
  parent_id              = local.resource_group_id
  type                   = "Microsoft.Insights/privateLinkScopes@2021-07-01-preview"
  response_export_values = []

  depends_on = [module.log_analytics_workspace]
}

# Private endpoint for the Log Analytics Workspace AMPLS, created outside the module
# to support azapi retry for transient 'AnotherOperationInProgress' errors.
resource "azapi_resource" "log_analytics_workspace_private_endpoint" {
  count = local.log_analytics_workspace_creation_enabled && local.virtual_network_enabled ? 1 : 0

  location  = var.location
  name      = "pep-${coalesce(var.log_analytics_workspace_name, module.naming.resource_names.azure_monitor_private_link_scope)}"
  parent_id = local.resource_group_id
  type      = "Microsoft.Network/privateEndpoints@2024-05-01"
  body = {
    properties = {
      subnet = {
        id = local.private_endpoint_subnet_id
      }
      privateLinkServiceConnections = [
        {
          name = "pse-${coalesce(var.log_analytics_workspace_name, module.naming.resource_names.azure_monitor_private_link_scope)}"
          properties = {
            privateLinkServiceId = data.azapi_resource.log_analytics_workspace_ampls[0].id
            groupIds             = ["azuremonitor"]
          }
        }
      ]
    }
  }
  response_export_values = []
  retry                  = var.log_analytics_workspace_retry
  tags                   = var.tags

  depends_on = [
    module.log_analytics_workspace,
    module.private_dns_zone_monitor,
    module.private_dns_zone_oms,
    module.private_dns_zone_ods,
    module.private_dns_zone_agentsvc,
    azapi_resource.application_insights_ampls_scoped_service
  ]
}

# Private DNS zone group for the Log Analytics Workspace private endpoint
resource "azapi_resource" "log_analytics_workspace_private_endpoint_dns_zone_group" {
  count = local.log_analytics_workspace_creation_enabled && local.virtual_network_enabled && local.create_private_dns_zone_monitor ? 1 : 0

  name      = "default"
  parent_id = azapi_resource.log_analytics_workspace_private_endpoint[0].id
  type      = "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01"
  body = {
    properties = {
      privateDnsZoneConfigs = [
        for i, zone_id in local.log_analytics_workspace_private_dns_zone_resource_ids : {
          name = "dnszone${i}"
          properties = {
            privateDnsZoneId = zone_id
          }
        }
      ]
    }
  }
  response_export_values = []
  retry                  = var.log_analytics_workspace_retry
}

# Link Application Insights to the AMPLS created by the LAW module
resource "azapi_resource" "application_insights_ampls_scoped_service" {
  count = local.log_analytics_workspace_creation_enabled && local.virtual_network_enabled && var.application_insights_enabled ? 1 : 0

  name      = module.naming.resource_names.ampls_appinsights_scoped_service
  parent_id = data.azapi_resource.log_analytics_workspace_ampls[0].id
  type      = "Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview"
  body = {
    properties = {
      linkedResourceId = module.application_insights[0].resource_id
    }
  }
  ignore_casing          = true
  response_export_values = []
  retry                  = var.log_analytics_workspace_retry

  depends_on = [module.log_analytics_workspace]
}
