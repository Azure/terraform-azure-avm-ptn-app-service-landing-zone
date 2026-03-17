output "app_service_environment" {
  description = "The App Service Environment resource output from the AVM module."
  value       = var.app_service_environment_enabled && var.app_service_environment_resource_id == null ? module.app_service_environment[0] : null
}

output "app_service_environment_id" {
  description = "The resource ID of the App Service Environment (created or BYO)."
  value       = local.app_service_environment_id
}

output "app_service_environment_name" {
  description = "The name of the App Service Environment."
  value       = var.app_service_environment_enabled && var.app_service_environment_resource_id == null ? module.app_service_environment[0].name : null
}

output "app_service_plan" {
  description = "The App Service Plan resource output from the AVM module."
  value       = var.app_service_plan_resource_id == null ? module.app_service_plan[0] : null
}

output "app_service_plan_id" {
  description = "The resource ID of the App Service Plan (created or BYO)."
  value       = local.app_service_plan_id
}

output "application_gateway" {
  description = "The Application Gateway resource output from the AVM module."
  value       = var.application_gateway_enabled && length(var.web_apps) > 0 ? module.application_gateway[0] : null
}

output "application_gateway_url" {
  description = "The FQDN URL of the Application Gateway public IP."
  value = var.application_gateway_enabled && length(var.web_apps) > 0 ? "https://${coalesce(
    var.application_gateway_public_ip_domain_name_label,
    module.naming.resource_names.application_gateway_public_ip_domain_name_label
  )}.${var.location}.cloudapp.azure.com" : null
}

output "application_insights" {
  description = "The Application Insights resource output from the AVM module."
  value       = var.application_insights_enabled && var.application_insights_resource_id == null ? module.application_insights[0] : null
}

output "application_insights_connection_string" {
  description = "The connection string of the Application Insights resource."
  sensitive   = true
  value       = local.application_insights_connection_string
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key of the Application Insights resource."
  sensitive   = true
  value       = local.application_insights_key
}

output "bastion_host" {
  description = "The Bastion Host resource output from the AVM module."
  value       = local.bastion_host_effectively_enabled && var.bastion_host_resource_id == null ? module.bastion_host[0] : null
}

output "bastion_host_id" {
  description = "The resource ID of the Bastion Host (created or BYO)."
  value       = var.bastion_host_resource_id != null ? var.bastion_host_resource_id : (local.bastion_host_effectively_enabled ? module.bastion_host[0].resource_id : null)
}

output "container_registry" {
  description = "The Container Registry resource output from the AVM module."
  value       = local.container_registry_effectively_enabled ? module.container_registry[0] : null
}

output "container_registry_id" {
  description = "The resource ID of the Container Registry (created or BYO)."
  value       = local.container_registry_id
}

output "container_registry_login_server" {
  description = "The login server URL of the Container Registry."
  value       = local.container_registry_effectively_enabled ? module.container_registry[0].resource.login_server : null
}

output "container_registry_name" {
  description = "The name of the Container Registry."
  value       = local.container_registry_effectively_enabled ? module.container_registry[0].name : null
}

output "front_door" {
  description = "The Azure Front Door resource output from the AVM module."
  value       = var.front_door_enabled && var.front_door_resource_id == null && length(var.web_apps) > 0 ? module.front_door[0] : null
}

output "key_vault" {
  description = "The Key Vault resource output from the AVM module."
  value       = length(module.key_vault) > 0 && var.key_vault_resource_id == null ? module.key_vault[0] : null
}

output "key_vault_id" {
  description = "The resource ID of the Key Vault (created or BYO)."
  value       = var.key_vault_resource_id != null ? var.key_vault_resource_id : (length(module.key_vault) > 0 ? module.key_vault[0].resource_id : null)
}

output "key_vault_name" {
  description = "The name of the Key Vault."
  value       = length(module.key_vault) > 0 && var.key_vault_resource_id == null ? module.key_vault[0].name : null
}

output "log_analytics_workspace" {
  description = "The Log Analytics workspace resource output from the AVM module."
  value       = local.log_analytics_workspace_creation_enabled ? module.log_analytics_workspace[0] : null
}

output "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace (created or BYO)."
  value       = local.log_analytics_workspace_resource_id
}

output "managed_instance_managed_identity_client_id" {
  description = "The client ID of the User-Assigned Managed Identity for the App Service Managed Instance plan default identity."
  value       = var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? module.managed_instance_managed_identity[0].client_id : null
}

output "managed_instance_managed_identity_id" {
  description = "The resource ID of the User-Assigned Managed Identity for the App Service Managed Instance plan default identity."
  value       = var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? module.managed_instance_managed_identity[0].resource_id : null
}

output "managed_instance_managed_identity_principal_id" {
  description = "The principal ID of the User-Assigned Managed Identity for the App Service Managed Instance plan default identity."
  value       = var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? module.managed_instance_managed_identity[0].principal_id : null
}

output "private_dns_zone_web" {
  description = "The private DNS zone for web apps (privatelink.azurewebsites.net) resource output."
  value       = local.create_private_dns_zone_web ? module.private_dns_zone_web[0] : null
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = local.resource_group_name
}

output "route_table" {
  description = "The ALZ route table resource output from the AVM module. Returns null when using a BYO route table."
  value       = var.alz_platform_landing_zone_route_table_resource_id == null && var.alz_platform_landing_zone_route_table_enabled ? module.alz_route_table[0] : null
}

output "route_table_id" {
  description = "The resource ID of the route table (created or BYO)."
  value       = local.route_table_id
}

output "storage_account" {
  description = "The Storage Account resource output from the AVM module."
  value       = length(module.storage_account) > 0 ? module.storage_account[0] : null
}

output "storage_account_id" {
  description = "The resource ID of the Storage Account (created or BYO)."
  value       = length(module.storage_account) > 0 ? module.storage_account[0].resource_id : null
}

output "storage_account_name" {
  description = "The name of the Storage Account."
  value       = length(module.storage_account) > 0 ? module.storage_account[0].name : null
}

output "virtual_network" {
  description = "The virtual network resource output from the AVM module."
  value       = var.virtual_network_enabled ? module.virtual_network[0] : null
}

output "virtual_network_id" {
  description = "The resource ID of the virtual network (created or BYO)."
  value       = local.virtual_network_id
}

output "virtual_network_name" {
  description = "The name of the virtual network."
  value       = var.virtual_network_enabled && var.virtual_network_resource_id == null ? module.virtual_network[0].name : null
}

output "web_app_managed_identities" {
  description = "A map of User-Assigned Managed Identities created for each web app, keyed by web app key."
  value = {
    for key, mi in module.web_app_managed_identity : key => {
      resource_id  = mi.resource_id
      principal_id = mi.principal_id
      client_id    = mi.client_id
    }
  }
}

output "web_app_slot_managed_identities" {
  description = "A map of User-Assigned Managed Identities created for each deployment slot, keyed by '{app_key}-{slot_key}'."
  value = {
    for key, mi in module.web_app_slot_managed_identity : key => {
      resource_id  = mi.resource_id
      principal_id = mi.principal_id
      client_id    = mi.client_id
    }
  }
}

output "web_apps" {
  description = "A map of web app resource outputs from the AVM module, keyed by the web_apps map key."
  value       = module.web_app
}
