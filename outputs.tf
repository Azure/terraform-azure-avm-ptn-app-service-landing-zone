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

output "front_door" {
  description = "The Azure Front Door resource output from the AVM module."
  value       = var.front_door_enabled && var.front_door_resource_id == null && length(var.web_apps) > 0 ? module.front_door[0] : null
}

output "key_vault" {
  description = "The Key Vault resource output from the AVM module."
  value       = var.key_vault_enabled && var.key_vault_resource_id == null ? module.key_vault[0] : null
}

output "key_vault_id" {
  description = "The resource ID of the Key Vault (created or BYO)."
  value       = var.key_vault_resource_id != null ? var.key_vault_resource_id : (var.key_vault_enabled ? module.key_vault[0].resource_id : null)
}

output "key_vault_name" {
  description = "The name of the Key Vault."
  value       = var.key_vault_enabled && var.key_vault_resource_id == null ? module.key_vault[0].name : null
}

output "managed_instance_managed_identity_id" {
  description = "The resource ID of the User-Assigned Managed Identity for the App Service Managed Instance plan default identity."
  value       = var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? module.managed_instance_managed_identity[0].resource_id : null
}

output "managed_instance_managed_identity_principal_id" {
  description = "The principal ID of the User-Assigned Managed Identity for the App Service Managed Instance plan default identity."
  value       = var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? module.managed_instance_managed_identity[0].principal_id : null
}

output "managed_instance_managed_identity_client_id" {
  description = "The client ID of the User-Assigned Managed Identity for the App Service Managed Instance plan default identity."
  value       = var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? module.managed_instance_managed_identity[0].client_id : null
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

output "private_dns_zone_web" {
  description = "The private DNS zone for web apps (privatelink.azurewebsites.net) resource output."
  value       = local.create_private_dns_zone_web ? module.private_dns_zone_web[0] : null
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = var.resource_group_name
}

output "route_table" {
  description = "The route table resource output from the AVM module."
  value       = var.egress_lockdown_enabled && var.firewall_private_ip != null ? module.route_table[0] : null
}

output "storage_account" {
  description = "The Storage Account resource output from the AVM module."
  value       = var.storage_account_enabled ? module.storage_account[0] : null
}

output "storage_account_id" {
  description = "The resource ID of the Storage Account (created or BYO)."
  value       = var.storage_account_enabled ? module.storage_account[0].resource_id : null
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

output "web_apps" {
  description = "A map of web app resource outputs from the AVM module, keyed by the web_apps map key."
  value       = module.web_app
}
