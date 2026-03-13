terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy          = false
      purge_soft_deleted_keys_on_destroy    = false
      purge_soft_deleted_secrets_on_destroy = false
    }
    storage {
      data_plane_available = false
    }
  }
  storage_use_azuread = true
}

data "azapi_client_config" "this" {}

resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"
}

module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.2"

  location         = local.azure_regions[random_integer.region_index.result]
  name             = "${module.naming.resource_group.name_unique}-managed-instance"
  enable_telemetry = var.enable_telemetry
}

module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"

  location            = module.resource_group.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry
}

# Archive the install scripts into a zip file
data "archive_file" "scripts" {
  type             = "zip"
  source_dir       = "${path.module}/scripts"
  output_path      = "${path.module}/scripts.zip"
  output_file_mode = "0644"
}

# ------------------------------------------------------------------
# Upload the sample app zip to a public storage account so the
# extensions/zipdeploy ARM API can fetch it via HTTPS URL.
# ------------------------------------------------------------------

module "storage_account_zip_deploy" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.7"

  location                      = module.resource_group.location
  name                          = module.naming.storage_account.name_unique
  resource_group_name           = module.resource_group.name
  account_replication_type      = "LRS"
  account_tier                  = "Standard"
  public_network_access_enabled = true
  network_rules                 = null
  containers = {
    zip-deploy = {
      name = "zip-deploy"
    }
  }
  enable_telemetry          = var.enable_telemetry
  shared_access_key_enabled = true
}

resource "azurerm_storage_blob" "zip_deploy" {
  name                   = "app.zip"
  storage_account_name   = module.storage_account_zip_deploy.name
  storage_container_name = "zip-deploy"
  type                   = "Block"
  source                 = "${path.module}/app.zip"
  content_md5            = filemd5("${path.module}/app.zip")

  depends_on = [module.storage_account_zip_deploy]
}

data "azurerm_storage_account_blob_container_sas" "zip_deploy" {
  connection_string = module.storage_account_zip_deploy.resource.primary_connection_string
  container_name    = "zip-deploy"
  start             = "2024-01-01T00:00:00Z"
  expiry            = "2099-01-01T00:00:00Z"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}

# App Service Managed Instance (WindowsManagedInstance)
# Provides enhanced security and performance features for Windows App Service.
# Bastion host is automatically enabled for WindowsManagedInstance mode.
# The os_type is automatically mapped to 'Windows' for web apps.
#
# The convenience variables (managed_instance_install_scripts, managed_instance_registry_adapters,
# managed_instance_storage_mounts) automatically handle:
#   - Creating the storage account with containers, blobs, and file shares
#   - Creating the key vault with secrets for registry adapters and storage connection strings
#   - Creating the managed identity and wiring it to the plan, key vault, and storage account
#   - Configuring private endpoints for all resources
module "test" {
  source = "../../"

  location  = module.resource_group.location
  parent_id = module.resource_group.resource_id
  # App Service Plan - WindowsManagedInstance with V4 SKU
  app_service_plan_os_type  = "WindowsManagedInstance"
  app_service_plan_sku_name = "P1v4"
  # RDP access enabled
  app_service_plan_rdp_enabled = true
  enable_telemetry             = var.enable_telemetry
  # Key Vault settings - the module auto-creates a key vault for registry adapters and storage mounts
  key_vault_purge_protection_enabled   = false
  key_vault_sku_name                   = "standard"
  key_vault_soft_delete_retention_days = 7
  key_vault_role_assignments = {
    secrets_officer = {
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = data.azapi_client_config.this.object_id
    }
  }
  log_analytics_workspace_resource_id = module.log_analytics_workspace.resource_id
  # Install scripts - just provide the name and path; the module handles container, blob, and ASP config
  managed_instance_install_scripts = [
    {
      name   = "CustomInstaller"
      source = data.archive_file.scripts.output_path
    }
  ]
  # Registry adapters - just provide the key, type, and value; the module handles KV secrets and ASP config
  managed_instance_registry_adapters = [
    {
      registry_key = "HKEY_LOCAL_MACHINE/SOFTWARE/MyApp1/RegistryAdapterString"
      type         = "String"
      value        = "MyExampleStringValue"
    },
    {
      registry_key = "HKEY_LOCAL_MACHINE/SOFTWARE/MyApp1/RegistryAdapterDWORD"
      type         = "DWORD"
      value        = "336"
    }
  ]
  # Storage mounts - just provide mount details; the module handles shares, KV secrets, and ASP config
  managed_instance_storage_mounts = [
    {
      name             = "g-drive"
      type             = "LocalStorage"
      destination_path = "G:\\"
    },
    {
      name             = "h-drive"
      type             = "AzureFiles"
      destination_path = "H:\\"
      share_name       = "hshare"
      share_quota      = 5
    }
  ]
  # Storage account settings - the module auto-creates a storage account for install scripts and mounts
  storage_account_role_assignments = {
    blob_contributor_current_user = {
      role_definition_id_or_name = "Storage Blob Data Contributor"
      principal_id               = data.azapi_client_config.this.object_id
    }
  }
  # Web apps
  web_apps = {
    app1 = {
      name            = module.naming.app_service.name_unique
      zip_deploy_file = nonsensitive("${azurerm_storage_blob.zip_deploy.url}${data.azurerm_storage_account_blob_container_sas.zip_deploy.sas}")
      app_settings = {
        SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
      }
      site_config = {
        always_on = true
        application_stack = {
          dotnet = {
            dotnet_version = "10.0"
            current_stack  = "dotnet"
          }
        }
      }
      deployment_slots = {
        uat = {
          name = "uat"
          site_config = {
            application_stack = {
              dotnet = {
                dotnet_version = "10.0"
                current_stack  = "dotnet"
              }
            }
          }
        }
        staging = {
          name = "staging"
          site_config = {
            application_stack = {
              dotnet = {
                dotnet_version = "10.0"
                current_stack  = "dotnet"
              }
            }
          }
        }
      }
    }
  }
}
