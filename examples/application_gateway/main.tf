terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    storage {
      data_plane_available = false
    }
  }
  storage_use_azuread = true
}

data "azurerm_client_config" "current" {}

resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.3"
}

module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.2"

  location         = local.azure_regions[random_integer.region_index.result]
  name             = "${module.naming.resource_group.name_unique}-appgw"
  enable_telemetry = var.enable_telemetry
}

# ------------------------------------------------------------------
# Upload the sample app zip to a public storage account so the
# extensions/zipdeploy ARM API can fetch it via HTTPS URL.
# ------------------------------------------------------------------

module "storage_account_zip_deploy" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.7"

  location                 = module.resource_group.location
  name                     = "${module.naming.storage_account.name_unique}test001"
  resource_group_name      = module.resource_group.name
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  containers = {
    zip-deploy = {
      name = "zip-deploy"
      role_assignments = {
        storage_blob_data_contributor = {
          role_definition_id_or_name = "Storage Blob Data Contributor"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    }
  }
  enable_telemetry              = var.enable_telemetry
  network_rules                 = null
  public_network_access_enabled = true
  shared_access_key_enabled     = true
}

resource "time_sleep" "wait_for_storage_account" {
  create_duration = "30s"

  depends_on = [module.storage_account_zip_deploy]
}

resource "azurerm_storage_blob" "zip_deploy" {
  name                   = "app.zip"
  storage_account_name   = module.storage_account_zip_deploy.name
  storage_container_name = "zip-deploy"
  type                   = "Block"
  content_md5            = filemd5("${path.module}/app.zip")
  source                 = "${path.module}/app.zip"

  depends_on = [time_sleep.wait_for_storage_account]
}

data "azurerm_storage_account_blob_container_sas" "zip_deploy" {
  connection_string = module.storage_account_zip_deploy.resource.primary_connection_string
  container_name    = "zip-deploy"
  expiry            = "2099-01-01T00:00:00Z"
  start             = "2024-01-01T00:00:00Z"

  permissions {
    add    = false
    create = false
    delete = false
    list   = false
    read   = true
    write  = false
  }
}

# ------------------------------------------------------------------
# Key Vault + self-signed TLS certificate for Application Gateway HTTPS.
# In production, replace with a real certificate.
#
# NOTE: This example uses a self-signed certificate, so browsers will
# show a security warning. You can bypass this in the browser to view
# the example application.
# ------------------------------------------------------------------

module "appgw_managed_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.4.0"

  location            = module.resource_group.location
  name                = "id-appgw-${module.naming.user_assigned_identity.name_unique}"
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry
}

module "appgw_key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.2"

  location            = module.resource_group.location
  name                = "kv-agw-${module.naming.key_vault.name_unique}"
  resource_group_name = module.resource_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  enable_telemetry    = var.enable_telemetry
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
  public_network_access_enabled = true
  purge_protection_enabled      = false
  role_assignments = {
    deployer_cert_officer = {
      role_definition_id_or_name = "Key Vault Certificates Officer"
      principal_id               = data.azurerm_client_config.current.object_id
    }
    appgw_secrets_user = {
      role_definition_id_or_name       = "Key Vault Secrets User"
      principal_id                     = module.appgw_managed_identity.principal_id
      skip_service_principal_aad_check = true
      principal_type                   = "ServicePrincipal"
    }
  }
  soft_delete_retention_days = 7
  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }
}

# Self-signed certificate - no AVM module exists for KV certificates (data plane operation)
resource "azurerm_key_vault_certificate" "appgw_self_signed" {
  key_vault_id = module.appgw_key_vault.resource_id
  name         = "appgw-self-signed"

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }
    key_properties {
      exportable = true
      key_type   = "RSA"
      reuse_key  = false
      key_size   = 4096
    }
    secret_properties {
      content_type = "application/x-pkcs12"
    }
    x509_certificate_properties {
      key_usage = [
        "digitalSignature",
        "keyEncipherment",
      ]
      subject            = "CN=appgateway.local"
      validity_in_months = 12
    }
  }

  depends_on = [module.appgw_key_vault]
}

# ------------------------------------------------------------------
# App Service Landing Zone with Application Gateway (WAF_v2).
# SSL certificate and managed identity are created above and passed in.
# ------------------------------------------------------------------

module "test" {
  source = "../../"

  location                    = module.resource_group.location
  parent_id                   = module.resource_group.resource_id
  application_gateway_enabled = true
  application_gateway_managed_identities = {
    user_assigned_resource_ids = [module.appgw_managed_identity.resource_id]
  }
  # Pass the SSL certificate and managed identity for Application Gateway
  application_gateway_ssl_certificates = {
    default = {
      name                = "appgw-self-signed"
      key_vault_secret_id = azurerm_key_vault_certificate.appgw_self_signed.versionless_secret_id
    }
  }
  enable_telemetry                               = var.enable_telemetry
  front_door_enabled                             = false
  log_analytics_workspace_internet_query_enabled = true
  web_apps = {
    app1 = {
      zip_deploy_file = nonsensitive("${azurerm_storage_blob.zip_deploy.url}${data.azurerm_storage_account_blob_container_sas.zip_deploy.sas}")
      app_settings = {
        SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
      }
      site_config = {
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
