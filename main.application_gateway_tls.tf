# Default self-signed TLS certificate for Application Gateway HTTPS listeners.
# Created in Key Vault when application_gateway_default_ssl_certificate_enabled = true
# and no custom ssl_certificates are provided.
# For production, provide your own certificate via var.application_gateway_ssl_certificates.

locals {
  application_gateway_default_ssl_enabled   = var.application_gateway_enabled && var.application_gateway_default_ssl_certificate_enabled && var.application_gateway_ssl_certificates == null
  application_gateway_default_ssl_cert_name = "appgw-default-cert"
  # Merge default SSL cert with any user-provided certs
  application_gateway_effective_ssl_certificates = local.application_gateway_default_ssl_enabled ? {
    default = {
      name                = local.application_gateway_default_ssl_cert_name
      key_vault_secret_id = azurerm_key_vault_certificate.application_gateway_default[0].versionless_secret_id
    }
  } : var.application_gateway_ssl_certificates
  # Merge default managed identity with any user-provided identities
  application_gateway_effective_managed_identities = local.application_gateway_default_ssl_enabled ? {
    system_assigned = var.application_gateway_managed_identities.system_assigned
    user_assigned_resource_ids = setunion(
      var.application_gateway_managed_identities.user_assigned_resource_ids,
      [module.application_gateway_managed_identity[0].resource_id]
    )
  } : var.application_gateway_managed_identities
}

# Managed identity for Application Gateway to access Key Vault certificates
module "application_gateway_managed_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.4.0"
  count   = local.application_gateway_default_ssl_enabled ? 1 : 0

  location            = var.location
  name                = coalesce(var.application_gateway_name, "${module.naming.resource_names.application_gateway}-id")
  resource_group_name = local.resource_group_name
  enable_telemetry    = var.enable_telemetry
  tags                = var.tags
}

# Self-signed certificate in Key Vault.
# NOTE: azurerm_key_vault_certificate is used because certificate creation is a
# data-plane operation not supported by azapi or any AVM module.
resource "azurerm_key_vault_certificate" "application_gateway_default" {
  count = local.application_gateway_default_ssl_enabled ? 1 : 0

  name         = local.application_gateway_default_ssl_cert_name
  key_vault_id = module.key_vault[0].resource_id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }
    key_properties {
      exportable = true
      key_size   = 4096
      key_type   = "RSA"
      reuse_key  = false
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
}
