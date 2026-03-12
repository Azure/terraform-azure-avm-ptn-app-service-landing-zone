locals {
  # App Service Environment
  app_service_environment_id = var.app_service_environment_resource_id != null ? var.app_service_environment_resource_id : (
    var.app_service_environment_enabled ? module.app_service_environment[0].resource_id : null
  )
  app_service_environment_subnet_id = var.app_service_environment_subnet_resource_id != null ? var.app_service_environment_subnet_resource_id : (
    var.virtual_network_enabled && var.app_service_environment_enabled ? (
      module.virtual_network[0].subnets["app_service_environment"].resource_id
    ) : null
  )
  # App Service Plan ID
  # When a BYO service plan ID is provided from azurerm_service_plan, the ID uses "serverFarms" (camelCase),
  # but Azure API normalizes to "serverfarms" (lowercase). The azapi-based web app module is case-sensitive,
  # causing an infinite plan diff. Normalize the casing to match Azure's convention.
  app_service_plan_id = var.app_service_plan_resource_id != null ? replace(var.app_service_plan_resource_id, "Microsoft.Web/serverFarms", "Microsoft.Web/serverfarms") : (
    var.app_service_plan_enabled ? module.app_service_plan[0].resource_id : null
  )
  # Subnet IDs
  app_service_subnet_id = var.app_service_subnet_resource_id != null ? var.app_service_subnet_resource_id : (
    var.virtual_network_enabled && !var.app_service_environment_enabled ? (
      module.virtual_network[0].subnets["app_service"].resource_id
    ) : null
  )
  # Application Insights - auto-wire connection string to web apps when AI is created by this module
  application_insights_connection_string = var.application_insights_enabled ? module.application_insights[0].connection_string : null
  application_insights_key               = var.application_insights_enabled ? module.application_insights[0].instrumentation_key : null
  # Bastion Host
  bastion_host_effectively_enabled = var.bastion_host_enabled
  bastion_host_subnet_id = var.bastion_host_subnet_resource_id != null ? var.bastion_host_subnet_resource_id : (
    var.virtual_network_enabled && local.bastion_host_effectively_enabled ? (
      module.virtual_network[0].subnets["AzureBastionSubnet"].resource_id
    ) : null
  )
  # Container Registry - auto-detect when any web app uses a container configuration
  container_apps_detected = anytrue([
    for _, app in var.web_apps : (
      try(app.site_config.application_stack.docker, null) != null ||
      try(app.site_config.windows_fx_version, null) != null
    )
  ])
  container_registry_effectively_enabled = var.container_registry_resource_id == null && var.container_registry_enabled
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
  container_registry_login_server = local.container_registry_effectively_enabled ? module.container_registry[0].resource.login_server : (
    var.container_registry_resource_id != null ? null : null
  )
  create_private_dns_zone_container_registry = var.private_dns_zones_enabled && var.virtual_network_enabled && local.container_registry_effectively_enabled && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  create_private_dns_zone_key_vault          = var.private_dns_zones_enabled && var.virtual_network_enabled && (var.key_vault_enabled || local.application_gateway_default_ssl_enabled || local.managed_instance_key_vault_needed) && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  create_private_dns_zone_storage_blob       = var.private_dns_zones_enabled && var.virtual_network_enabled && (var.storage_account_enabled || local.managed_instance_storage_account_needed) && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  create_private_dns_zone_storage_file       = var.private_dns_zones_enabled && var.virtual_network_enabled && (var.storage_account_enabled || local.managed_instance_storage_account_needed) && length(merge(var.storage_account_shares, local.managed_instance_shares)) > 0 && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  # Private DNS Zone
  create_private_dns_zone_web = var.private_dns_zones_enabled && var.virtual_network_enabled && !var.alz_platform_landing_zone_private_dns_zone_mode_enabled
  # App Service Plan - auto-adjust SKU for ASE (Isolated tier required)
  effective_sku_name = var.app_service_environment_enabled && !startswith(var.app_service_plan_sku_name, "I") ? "I1v2" : var.app_service_plan_sku_name
  # Managed Identity for Managed Instance - used for plan default identity
  managed_instance_managed_identity_resource_id = var.app_service_plan_os_type == "WindowsManagedInstance" && var.managed_instance_managed_identity_enabled ? module.managed_instance_managed_identity[0].resource_id : null
  private_dns_zone_web_id = var.private_dns_zone_web_resource_id != null ? var.private_dns_zone_web_resource_id : (
    local.create_private_dns_zone_web ? module.private_dns_zone_web[0].resource_id : null
  )
  private_endpoint_subnet_id = var.private_endpoint_subnet_resource_id != null ? var.private_endpoint_subnet_resource_id : (
    var.virtual_network_enabled ? (
      module.virtual_network[0].subnets["private_endpoints"].resource_id
    ) : null
  )
  resource_group_id   = var.parent_id
  resource_group_name = provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id).resource_group_name
  # Virtual networking
  virtual_network_enabled = var.virtual_network_enabled
  virtual_network_id = var.virtual_network_resource_id != null ? var.virtual_network_resource_id : (
    var.virtual_network_enabled ? module.virtual_network[0].resource_id : null
  )
  # Web App OS type - WindowsManagedInstance and WindowsContainer plans host Windows web apps
  web_app_default_os_type = contains(["WindowsManagedInstance", "WindowsContainer"], var.app_service_plan_os_type) ? "Windows" : var.app_service_plan_os_type

  # ============================================================
  # Managed Instance convenience variable computed values
  # ============================================================

  # Whether any convenience variables are in use
  managed_instance_convenience_enabled = var.app_service_plan_os_type == "WindowsManagedInstance" && (
    length(var.managed_instance_install_scripts) > 0 ||
    length(var.managed_instance_registry_adapters) > 0 ||
    length(var.managed_instance_storage_mounts) > 0
  )

  # Auto-enable key vault when convenience variables need it
  managed_instance_key_vault_needed = length(var.managed_instance_registry_adapters) > 0 || length([
    for m in var.managed_instance_storage_mounts : m if m.type == "AzureFiles"
  ]) > 0

  # Auto-enable storage account when convenience variables need it
  managed_instance_storage_account_needed = length(var.managed_instance_install_scripts) > 0 || length([
    for m in var.managed_instance_storage_mounts : m if m.type == "AzureFiles"
  ]) > 0

  # Whether any AzureFiles mounts require shared access keys
  managed_instance_shared_access_key_needed = length([
    for m in var.managed_instance_storage_mounts : m if m.type == "AzureFiles"
  ]) > 0

  # Storage account name - computed once, used when building URIs at plan time
  managed_instance_storage_account_name = coalesce(var.storage_account_name, module.naming.resource_names.storage_account)

  # Key vault name - computed once, used when building URIs at plan time
  managed_instance_key_vault_name = coalesce(var.key_vault_name, module.naming.resource_names.key_vault)

  # --- Containers derived from install scripts ---
  managed_instance_containers = {
    for idx, script in var.managed_instance_install_scripts :
    "mi_install_${idx}" => {
      name          = "install-scripts-${idx}"
      public_access = "None"
    }
  }

  # --- Blobs derived from install scripts ---
  managed_instance_blobs = {
    for idx, script in var.managed_instance_install_scripts :
    "mi_install_${idx}" => {
      name           = "${script.name}.zip"
      container_name = "install-scripts-${idx}"
      type           = "Block"
      source         = script.source
    }
  }

  # --- Install scripts config for the ASP ---
  managed_instance_install_scripts_config = [
    for idx, script in var.managed_instance_install_scripts : {
      name = script.name
      source = {
        type       = "RemoteAzureBlob"
        source_uri = "https://${local.managed_instance_storage_account_name}.blob.core.windows.net/install-scripts-${idx}/${script.name}.zip"
      }
    }
  ]

  # --- Key vault secrets for registry adapters ---
  managed_instance_registry_adapter_secrets = {
    for idx, adapter in var.managed_instance_registry_adapters :
    "mi_registry_${idx}" => {
      name = "mi-registry-adapter-${idx}"
    }
  }

  managed_instance_registry_adapter_secrets_value = {
    for idx, adapter in var.managed_instance_registry_adapters :
    "mi_registry_${idx}" => adapter.value
  }

  # --- Registry adapters config for the ASP ---
  managed_instance_registry_adapters_config = [
    for idx, adapter in var.managed_instance_registry_adapters : {
      registry_key = adapter.registry_key
      type         = adapter.type
      key_vault_secret_reference = {
        secret_uri = "https://${local.managed_instance_key_vault_name}.vault.azure.net/secrets/mi-registry-adapter-${idx}"
      }
    }
  ]

  # --- Shares derived from AzureFiles storage mounts ---
  managed_instance_shares = {
    for mount in var.managed_instance_storage_mounts :
    "mi_share_${mount.share_name}" => {
      name  = mount.share_name
      quota = mount.share_quota
    }
    if mount.type == "AzureFiles" && mount.share_name != null
  }

  # --- Storage mounts config for the ASP ---
  managed_instance_storage_mounts_config = [
    for mount in var.managed_instance_storage_mounts : mount.type == "AzureFiles" ? {
      name             = mount.name
      type             = "AzureFiles"
      source           = "\\\\${local.managed_instance_storage_account_name}.file.core.windows.net\\${mount.share_name}"
      destination_path = mount.destination_path
      credentials_key_vault_reference = {
        # NOTE: the double slash after the vault URI is intentional to comply with Key Vault secret URI format for this resource
        secret_uri = "https://${local.managed_instance_key_vault_name}.vault.azure.net//secrets/mi-storage-connection-string"
      }
      } : {
      name             = mount.name
      type             = "LocalStorage"
      source           = ""
      destination_path = mount.destination_path
      credentials_key_vault_reference = {
        secret_uri = null
      }
    }
  ]
}
