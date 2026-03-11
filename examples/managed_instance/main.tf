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

# A user-assigned managed identity for the Managed Instance plan default identity
module "managed_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.4.0"

  location            = module.resource_group.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry
}

# Storage account to host the install scripts package and file shares
# Role assignments are managed via the AVM module's role_assignments interface
module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.7"

  location                 = module.resource_group.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = module.resource_group.name
  access_tier              = "Hot"
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  containers = {
    scripts = {
      name          = "scripts"
      public_access = "None"
    }
  }
  enable_telemetry = var.enable_telemetry
  network_rules = {
    default_action = "Allow"
  }
  role_assignments = {
    blob_reader = {
      role_definition_id_or_name       = "Storage Blob Data Reader"
      principal_id                     = module.managed_identity.principal_id
      skip_service_principal_aad_check = true
      principal_type                   = "ServicePrincipal"
    }
    blob_contributor_current_user = {
      role_definition_id_or_name = "Storage Blob Data Contributor"
      principal_id               = data.azapi_client_config.this.object_id
    }
  }
  shared_access_key_enabled = true
  shares = {
    hshare = {
      name  = "hshare"
      quota = 5
    }
  }
}

# Key Vault for storing secrets used by the Managed Instance plan
# Role assignments and secrets are managed via the AVM module's interfaces
module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.2"

  location                       = module.resource_group.location
  name                           = module.naming.key_vault.name_unique
  resource_group_name            = module.resource_group.name
  tenant_id                      = data.azapi_client_config.this.tenant_id
  enable_telemetry               = var.enable_telemetry
  legacy_access_policies_enabled = false
  purge_protection_enabled       = false
  role_assignments = {
    secrets_officer = {
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = data.azapi_client_config.this.object_id
    }
    secrets_user = {
      role_definition_id_or_name       = "Key Vault Secrets User"
      principal_id                     = module.managed_identity.principal_id
      skip_service_principal_aad_check = true
      principal_type                   = "ServicePrincipal"
    }
  }
  secrets = {
    storage_key = {
      name = "storage-account-key"
    }
    registry_string = {
      name = "registry-string-value"
    }
    registry_dword = {
      name = "registry-dword-value"
    }
  }
  secrets_value = {
    storage_key     = "DefaultEndpointsProtocol=https;AccountName=${module.storage_account.name};AccountKey=${data.azapi_resource_action.storage_account_keys.output.keys[0].value};EndpointSuffix=core.windows.net"
    registry_string = "MyExampleStringValue"
    registry_dword  = "336"
  }
  sku_name                   = "standard"
  soft_delete_retention_days = 7
}

# Retrieve the storage account keys
data "azapi_resource_action" "storage_account_keys" {
  action                 = "listKeys"
  resource_id            = module.storage_account.resource_id
  type                   = "Microsoft.Storage/storageAccounts@2023-05-01"
  response_export_values = ["keys"]
}

# Archive the install scripts into a zip file
data "archive_file" "scripts" {
  type             = "zip"
  source_dir       = "${path.module}/scripts"
  output_path      = "${path.module}/scripts.zip"
  output_file_mode = "0644"
}

# Upload scripts.zip as a placeholder for the install script package.
# NOTE: azurerm_storage_blob is retained here because blob upload is a data plane
# operation not supported by azapi or any AVM module.
resource "azurerm_storage_blob" "scripts_zip" {
  name                   = "scripts.zip"
  storage_account_name   = module.storage_account.name
  storage_container_name = "scripts"
  type                   = "Block"
  content_md5            = data.archive_file.scripts.output_md5
  source                 = data.archive_file.scripts.output_path

  depends_on = [module.storage_account]
}

# App Service Managed Instance (WindowsManagedInstance)
# Provides enhanced security and performance features for Windows App Service.
# Bastion host is automatically enabled for WindowsManagedInstance mode.
# The os_type is automatically mapped to 'Windows' for web apps.
module "test" {
  source = "../../"

  location  = module.resource_group.location
  parent_id = module.resource_group.resource_id
  # Install scripts - references the scripts.zip blob in the storage account
  # The install script logs can be found in C:\\InstallScripts on the VM instances
  app_service_plan_install_scripts = [
    {
      name = "CustomInstaller"
      source = {
        type       = "RemoteAzureBlob"
        source_uri = "https://${module.storage_account.name}.blob.core.windows.net/scripts/scripts.zip"
      }
    }
  ]
  # Managed identities on the plan
  app_service_plan_managed_identities = {
    user_assigned_resource_ids = [module.managed_identity.resource_id]
  }
  # App Service Plan - WindowsManagedInstance with V4 SKU
  app_service_plan_os_type = "WindowsManagedInstance"
  # Plan default identity - used by the platform to pull install scripts
  app_service_plan_plan_default_identity = {
    identity_type                      = "UserAssigned"
    user_assigned_identity_resource_id = module.managed_identity.resource_id
  }
  # RDP access enabled
  app_service_plan_rdp_enabled = true
  # Registry adapters - configure Windows registry keys via Key Vault references
  app_service_plan_registry_adapters = [
    {
      registry_key = "HKEY_LOCAL_MACHINE/SOFTWARE/MyApp1/RegistryAdapterString"
      type         = "String"
      key_vault_secret_reference = {
        secret_uri = "https://${module.key_vault.name}.vault.azure.net/secrets/registry-string-value"
      }
    },
    {
      registry_key = "HKEY_LOCAL_MACHINE/SOFTWARE/MyApp1/RegistryAdapterDWORD"
      type         = "DWORD"
      key_vault_secret_reference = {
        secret_uri = "https://${module.key_vault.name}.vault.azure.net/secrets/registry-dword-value"
      }
    }
  ]
  app_service_plan_sku_name = "P1v4"
  # Storage mounts - G: drive (local) and H: drive (Azure Files)
  app_service_plan_storage_mounts = [
    {
      name             = "g-drive"
      type             = "LocalStorage"
      destination_path = "G:\\"
    },
    {
      name             = "h-drive"
      type             = "AzureFiles"
      source           = "\\\\${module.storage_account.name}.file.core.windows.net\\hshare"
      destination_path = "H:\\"
      credentials_key_vault_reference = {
        # NOTE: the double slash after the vault URI is intentional to comply with Key Vault secret URI format for this resource
        secret_uri = "https://${module.key_vault.name}.vault.azure.net//secrets/storage-account-key"
      }
    }
  ]
  # Networking - bastion is auto-enabled for WindowsManagedInstance
  enable_telemetry                    = var.enable_telemetry
  log_analytics_workspace_resource_id = module.log_analytics_workspace.resource_id
  # Web apps
  web_apps = {
    app1 = {
      name = module.naming.app_service.name_unique
      site_config = {
        always_on = true
        application_stack = {
          dotnet = {
            dotnet_version = "v10.0"
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
                dotnet_version = "v10.0"
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
                dotnet_version = "v10.0"
                current_stack  = "dotnet"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [azurerm_storage_blob.scripts_zip]
}
