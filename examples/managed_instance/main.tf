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

resource "azurerm_resource_group" "this" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = "${module.naming.resource_group.name_unique}-managed-instance"
}

# A user-assigned managed identity for the Managed Instance plan default identity
resource "azapi_resource" "managed_identity" {
  location               = azurerm_resource_group.this.location
  name                   = module.naming.user_assigned_identity.name_unique
  parent_id              = azurerm_resource_group.this.id
  type                   = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31"
  response_export_values = ["properties.principalId"]
}

# Storage account to host the install scripts package and file shares
resource "azapi_resource" "storage_account" {
  location  = azurerm_resource_group.this.location
  name      = module.naming.storage_account.name_unique
  parent_id = azurerm_resource_group.this.id
  type      = "Microsoft.Storage/storageAccounts@2023-05-01"
  body = {
    kind = "StorageV2"
    properties = {
      accessTier               = "Hot"
      allowBlobPublicAccess    = false
      allowSharedKeyAccess     = true
      minimumTlsVersion        = "TLS1_2"
      supportsHttpsTrafficOnly = true
      publicNetworkAccess      = "Enabled"
      networkAcls = {
        defaultAction = "Allow"
      }
    }
    sku = {
      name = "Standard_ZRS"
    }
  }
  response_export_values = []
}

# Blob container to hold scripts.zip
resource "azapi_resource" "blob_container" {
  name      = "scripts"
  parent_id = "${azapi_resource.storage_account.id}/blobServices/default"
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01"
  body = {
    properties = {
      publicAccess = "None"
    }
  }
  response_export_values = []
}

# File share for H: drive mount
resource "azapi_resource" "file_share" {
  name      = "hshare"
  parent_id = "${azapi_resource.storage_account.id}/fileServices/default"
  type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01"
  body = {
    properties = {
      shareQuota = 5
    }
  }
  response_export_values = []
}

# Grant the managed identity "Storage Blob Data Reader" on the storage account
# so the plan can pull install scripts
resource "azapi_resource" "role_assignment_blob_reader" {
  name      = "7d2b4b60-b4a1-4e5e-a123-abcdef012345"
  parent_id = azapi_resource.storage_account.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId      = azapi_resource.managed_identity.output.properties.principalId
      principalType    = "ServicePrincipal"
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.this.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1"
    }
  }
  response_export_values = []

  depends_on = [azapi_resource.blob_container]
}

# Grant the current user "Storage Blob Data Contributor" on the storage account
# so the azurerm provider can upload the blob via Azure AD auth
resource "azapi_resource" "role_assignment_blob_contributor_current_user" {
  name      = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
  parent_id = azapi_resource.storage_account.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId      = data.azapi_client_config.this.object_id
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.this.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
    }
  }
  response_export_values = []

  depends_on = [azapi_resource.blob_container]
}

# Key Vault for storing secrets used by the Managed Instance plan
resource "azapi_resource" "key_vault" {
  location  = azurerm_resource_group.this.location
  name      = module.naming.key_vault.name_unique
  parent_id = azurerm_resource_group.this.id
  type      = "Microsoft.KeyVault/vaults@2023-07-01"
  body = {
    properties = {
      enablePurgeProtection        = null
      enableRbacAuthorization      = true
      enableSoftDelete             = false
      enabledForDeployment         = false
      enabledForTemplateDeployment = false
      sku = {
        family = "A"
        name   = "standard"
      }
      tenantId = data.azapi_client_config.this.tenant_id
    }
  }
  response_export_values = []
}

# Grant the current user "Key Vault Secrets Officer" so we can create secrets
resource "azapi_resource" "role_assignment_kv_secrets_officer" {
  name      = "b1c2d3e4-f5a6-7890-abcd-ef1234567891"
  parent_id = azapi_resource.key_vault.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId      = data.azapi_client_config.this.object_id
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.this.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b86a8fe4-44ce-4948-aee5-eccb2c155cd7"
    }
  }
  response_export_values = []
}

# Grant the managed identity "Key Vault Secrets User" on the Key Vault
# so the App Service Plan can read secrets for registry adapters and storage mount credentials
resource "azapi_resource" "role_assignment_kv_secrets_user" {
  name      = "c2d3e4f5-a6b7-8901-bcde-f12345678902"
  parent_id = azapi_resource.key_vault.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId      = azapi_resource.managed_identity.output.properties.principalId
      principalType    = "ServicePrincipal"
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.this.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6"
    }
  }
  response_export_values = []
}

# Retrieve the storage account keys
data "azapi_resource_action" "storage_account_keys" {
  action                 = "listKeys"
  resource_id            = azapi_resource.storage_account.id
  type                   = "Microsoft.Storage/storageAccounts@2023-05-01"
  response_export_values = ["keys"]
}

# Store the storage account connection string in Key Vault as a secret
resource "azurerm_key_vault_secret" "storage_key" {
  key_vault_id = azapi_resource.key_vault.id
  name         = "storage-account-key"
  value        = "DefaultEndpointsProtocol=https;AccountName=${azapi_resource.storage_account.name};AccountKey=${data.azapi_resource_action.storage_account_keys.output.keys[0].value};EndpointSuffix=core.windows.net"

  depends_on = [azapi_resource.role_assignment_kv_secrets_officer]
}

# Key Vault secret for a registry adapter string value
resource "azurerm_key_vault_secret" "registry_string" {
  key_vault_id = azapi_resource.key_vault.id
  name         = "registry-string-value"
  value        = "MyExampleStringValue"

  depends_on = [azapi_resource.role_assignment_kv_secrets_officer]
}

# Key Vault secret for a registry adapter DWORD value
resource "azurerm_key_vault_secret" "registry_dword" {
  key_vault_id = azapi_resource.key_vault.id
  name         = "registry-dword-value"
  value        = "336" # Must be an Integer

  depends_on = [azapi_resource.role_assignment_kv_secrets_officer]
}

# Archive the install scripts into a zip file
data "archive_file" "scripts" {
  type             = "zip"
  source_dir       = "${path.module}/scripts"
  output_path      = "${path.module}/scripts.zip"
  output_file_mode = "0644"
}

# Upload scripts.zip as a placeholder for the install script package
resource "azurerm_storage_blob" "scripts_zip" {
  name                   = "scripts.zip"
  storage_account_name   = azapi_resource.storage_account.name
  storage_container_name = azapi_resource.blob_container.name
  type                   = "Block"
  content_md5            = data.archive_file.scripts.output_md5
  source                 = data.archive_file.scripts.output_path

  depends_on = [azapi_resource.role_assignment_blob_reader, azapi_resource.role_assignment_blob_contributor_current_user]
}

# App Service Managed Instance (WindowsManagedInstance)
# Provides enhanced security and performance features for Windows App Service.
# Bastion host is automatically enabled for WindowsManagedInstance mode.
# The os_type is automatically mapped to 'Windows' for web apps.
module "test" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.app_service.name_unique
  resource_group_name = azurerm_resource_group.this.name
  # Install scripts - references the scripts.zip blob in the storage account
  # The install script logs can be found in C:\InstallScripts on the VM instances
  app_service_plan_install_scripts = [
    {
      name = "CustomInstaller"
      source = {
        type       = "RemoteAzureBlob"
        source_uri = "https://${azapi_resource.storage_account.name}.blob.core.windows.net/${azapi_resource.blob_container.name}/scripts.zip"
      }
    }
  ]
  # Managed identities on the plan
  app_service_plan_managed_identities = {
    user_assigned_resource_ids = [azapi_resource.managed_identity.id]
  }
  # App Service Plan - WindowsManagedInstance with V4 SKU
  app_service_plan_os_type = "WindowsManagedInstance"
  # Plan default identity - used by the platform to pull install scripts
  app_service_plan_plan_default_identity = {
    identity_type                      = "UserAssigned"
    user_assigned_identity_resource_id = azapi_resource.managed_identity.id
  }
  # RDP access enabled
  app_service_plan_rdp_enabled = true
  # Registry adapters - configure Windows registry keys via Key Vault references
  app_service_plan_registry_adapters = [
    {
      registry_key = "HKEY_LOCAL_MACHINE/SOFTWARE/MyApp1/RegistryAdapterString"
      type         = "String"
      key_vault_secret_reference = {
        secret_uri = "https://${azapi_resource.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.registry_string.name}"
      }
    },
    {
      registry_key = "HKEY_LOCAL_MACHINE/SOFTWARE/MyApp1/RegistryAdapterDWORD"
      type         = "DWORD"
      key_vault_secret_reference = {
        secret_uri = "https://${azapi_resource.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.registry_dword.name}"
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
      source           = "\\\\${azapi_resource.storage_account.name}.file.core.windows.net\\${azapi_resource.file_share.name}"
      destination_path = "H:\\"
      credentials_key_vault_reference = {
        # NOTE: the double slash after the vault URI is intentional to comply with Key Vault secret URI format for this resource
        secret_uri = "https://${azapi_resource.key_vault.name}.vault.azure.net//secrets/${azurerm_key_vault_secret.storage_key.name}"
      }
    }
  ]
  app_service_plan_worker_count           = 3
  app_service_plan_zone_balancing_enabled = true
  # Networking - bastion is auto-enabled for WindowsManagedInstance
  enable_telemetry          = var.enable_telemetry
  front_door_enabled        = true
  private_dns_zones_enabled = true
  virtual_network_enabled   = true
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
      managed_identities = {
        system_assigned = true
      }
      deployment_slots = {
        dev = {
          name = "dev"
          site_config = {
            application_stack = {
              dotnet = {
                dotnet_version = "v10.0"
                current_stack  = "dotnet"
              }
            }
          }
        }
        stage = {
          name = "stage"
          site_config = {
            application_stack = {
              dotnet = {
                dotnet_version = "v10.0"
                current_stack  = "dotnet"
              }
            }
          }
        }
        prod = {
          name = "prod"
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
