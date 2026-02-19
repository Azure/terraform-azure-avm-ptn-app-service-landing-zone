output "app_service_environment" {
  description = "The App Service Environment resource output from the AVM module."
  value       = var.app_service_environment_enabled && var.app_service_environment_resource_id == null ? module.app_service_environment[0] : null
}

output "app_service_environment_id" {
  description = "The resource ID of the App Service Environment (created or BYO)."
  value       = local.app_service_environment_id
}

output "app_service_plan" {
  description = "The App Service Plan resource output from the AVM module."
  value       = var.app_service_plan_resource_id == null ? module.app_service_plan[0] : null
}

output "app_service_plan_id" {
  description = "The resource ID of the App Service Plan (created or BYO)."
  value       = local.app_service_plan_id
}

output "front_door" {
  description = "The Azure Front Door resource output from the AVM module."
  value       = var.front_door_enabled && var.front_door_resource_id == null && length(var.web_apps) > 0 ? module.front_door[0] : null
}

output "private_dns_zone_web" {
  description = "The private DNS zone for web apps (privatelink.azurewebsites.net) resource output."
  value       = local.create_private_dns_zone_web ? module.private_dns_zone_web[0] : null
}

output "virtual_network" {
  description = "The virtual network resource output from the AVM module."
  value       = var.virtual_network_enabled && var.virtual_network_resource_id == null ? module.virtual_network[0] : null
}

output "virtual_network_id" {
  description = "The resource ID of the virtual network (created or BYO)."
  value       = local.virtual_network_id
}

output "web_apps" {
  description = "A map of web app resource outputs from the AVM module, keyed by the web_apps map key."
  value       = module.web_app
}
