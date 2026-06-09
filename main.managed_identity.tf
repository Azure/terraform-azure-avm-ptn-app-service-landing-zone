# Managed Identity for App Service Managed Instance plan default identity.
# This identity is used by the platform to pull install scripts, access registry adapters, etc.
module "managed_instance_managed_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.5.0"
  count   = var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? 1 : 0

  location            = var.location
  name                = coalesce(var.managed_instance_managed_identity_name, module.naming.resource_names.managed_identity)
  resource_group_name = local.resource_group_name
  enable_telemetry    = var.enable_telemetry
  tags                = var.tags
}

# Per-web-app User-Assigned Managed Identities.
# Each web app can have its own managed identity, controlled by the managed_identity_enabled field.
module "web_app_managed_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.5.0"
  for_each = {
    for key, app in var.web_apps : key => app
    if app.managed_identity_enabled
  }

  location            = var.location
  name                = coalesce(each.value.managed_identity_name, module.naming.resource_names.web_app_managed_identity[each.key])
  resource_group_name = local.resource_group_name
  enable_telemetry    = var.enable_telemetry
  tags                = var.tags
}

# Per-slot User-Assigned Managed Identities.
# Each deployment slot can have its own managed identity, controlled by the managed_identity_enabled field on the slot.
module "web_app_slot_managed_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.5.0"
  for_each = {
    for item in flatten([
      for app_key, app in var.web_apps : [
        for slot_key, slot in app.deployment_slots : {
          key      = "${app_key}-${slot_key}"
          app_name = app.name
          slot     = slot
          slot_key = slot_key
        }
        if slot.managed_identity_enabled
      ]
    ]) : item.key => item
  }

  location            = var.location
  name                = coalesce(each.value.slot.managed_identity_name, module.naming.resource_names.web_app_slot_managed_identity[each.key])
  resource_group_name = local.resource_group_name
  enable_telemetry    = var.enable_telemetry
  tags                = var.tags
}
