locals {
  # AcrPull role assignments for all web app and slot managed identities
  container_registry_acr_pull_role_assignments = merge(
    {
      for key, app in var.web_apps : "acr_pull_${key}" => {
        role_definition_id_or_name       = "AcrPull"
        principal_id                     = module.web_app_managed_identity[key].principal_id
        skip_service_principal_aad_check = true
        principal_type                   = "ServicePrincipal"
      }
      if app.managed_identity_enabled
    },
    {
      for item in flatten([
        for app_key, app in var.web_apps : [
          for slot_key, slot in app.deployment_slots : {
            key      = "acr_pull_${app_key}_${slot_key}"
            app_key  = app_key
            slot_key = slot_key
          }
          if slot.managed_identity_enabled
        ]
        ]) : item.key => {
        role_definition_id_or_name       = "AcrPull"
        principal_id                     = module.web_app_slot_managed_identity["${item.app_key}-${item.slot_key}"].principal_id
        skip_service_principal_aad_check = true
        principal_type                   = "ServicePrincipal"
      }
    }
  )
  container_registry_effectively_enabled     = var.container_registry_resource_id == null && var.container_registry_enabled
  create_private_dns_zone_container_registry = var.private_dns_zone_container_registry_resource_id == null && var.private_dns_zones_enabled && var.virtual_network_enabled && local.container_registry_effectively_enabled && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
}
