# Azure App Service Application Landing Zone

This module deploys a production-ready Azure App Service hosting environment with enterprise-grade networking, security, and observability. It follows the [Azure App Service Landing Zone Accelerator](https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/app-platform/app-services/landing-zone-accelerator) architecture and is built using [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/).

Examples that use zip deployment run `pre.ps1` to package the upstream ASP.NET sample at commit `19b1e5f8843ca8c36c41aa701823a4f18ee78c53`, targeting .NET 10 to match their App Service runtime. This requires Git and PowerShell 7.4 or later; App Service builds the source archive during deployment.

Terraform validation does not require a prebuilt archive. Planning and deployment require the genuine `app.zip`; a missing archive fails with instructions to run the example's `pre.ps1`.

## Upgrading existing deployments

This version requires Terraform 1.16 or later. Back up state securely and review the plan for unexpected changes, replacements, or deletions before applying. The historical-state procedures below have not been tested against a deployed instance of this pattern.

### Application Gateway

The default configuration retains inline WAF settings and does not resolve Azure's previously observed `ApplicationGatewayWafConfigurationDeprecated` rejection. Azure no longer permits new WAF v2 deployments with legacy WAF configuration; see [Microsoft's WAF policy migration guidance](https://learn.microsoft.com/azure/web-application-firewall/ag/upgrade-ag-waf-policy). Migrating an existing gateway does not by itself reconcile the inline settings in this Terraform configuration.

If this pattern created an Application Gateway public IP, the gateway module upgrade requires transferring that existing IP into the new module's state. After updating and initializing the configuration, inspect the existing IP's Azure resource ID with `terraform state show`. Replace `landing_zone` below with your pattern module address and `<public-ip-resource-id>` with that existing ID. Do not apply between removal and import.

```powershell
terraform state pull > terraform.tfstate.backup
terraform state show 'module.landing_zone.module.application_gateway[0].azurerm_public_ip.this[0]'
terraform state rm 'module.landing_zone.module.application_gateway[0].azurerm_public_ip.this[0]'
terraform import `
  'module.landing_zone.module.application_gateway[0].azapi_resource.public_ip_addresses["default"]' `
  '<public-ip-resource-id>'
terraform plan
```

Stop if the plan proposes replacing or deleting the public IP or gateway. See the [gateway upgrade guide](https://github.com/Azure/terraform-azurerm-avm-res-network-applicationgateway/blob/v0.6.0/UPGRADE.md) for the underlying state migration.

The `application_gateway` output now exposes the upgraded child module's outputs. Replace `application_gateway_id` with `resource_id`, `application_gateway_name` with `name`, `public_ip_id` with `public_ip_addresses["default"].resource_id`, and `new_public_ip_address` with `public_ip_addresses["default"].ip_address`. The previous `backend_address_pools`, `backend_http_settings`, `frontend_port`, `http_listeners`, `probes`, `request_routing_rules`, `ssl_certificates`, `tags`, and `waf_configuration` outputs are no longer available.

Sensitive certificate inputs can cause Terraform to warn that a gateway validation message refers to sensitive values.

### Log Analytics workspace

On the first upgrade plan, workspace shared keys can be unknown until apply. If downstream resources depend on those keys, review the plan carefully and stop if it proposes unintended changes or replacements. The child module's optional migration switch is not exposed by this pattern. If needed, separately plan and apply only `module.landing_zone.module.log_analytics_workspace`, review that targeted plan and its dependencies first, and then run a full plan before applying other changes. Targeted applies are exceptional and this sequence has not been tested against historical state.

The workspace module has its own private-endpoint DNS migration guidance in its [upgrade notes](https://github.com/Azure/terraform-azurerm-avm-res-operationalinsights-workspace/blob/v0.7.0/_header.md). This pattern manages its AMPLS private endpoint and DNS zone group separately; do not apply the child-module DNS import instructions to those resources.

### Storage accounts and Key Vault

The storage account upgrade moves containers and file shares into child modules. For every existing key, add the applicable `moved` block in your root configuration before planning. Replace `landing_zone` and the example keys with the actual module address and keys from state, including any managed-instance keys.

```hcl
moved {
  from = module.landing_zone.module.storage_account[0].azapi_resource.containers["example"]
  to   = module.landing_zone.module.storage_account[0].module.containers["example"].azapi_resource.this
}

moved {
  from = module.landing_zone.module.storage_account[0].azapi_resource.share["example"]
  to   = module.landing_zone.module.storage_account[0].module.shares["example"].azapi_resource.this
}
```

Keep the blocks for every workspace and stop if the plan proposes replacing or deleting storage resources. Review the [storage account upgrade guide](https://github.com/Azure/terraform-azurerm-avm-res-storage-storageaccount/blob/v0.11.0/_header.md) for role assignments, diagnostics, and sovereign-cloud caveats.

If the Key Vault module managed a private endpoint DNS zone group, import that existing zone group before applying. The pattern's endpoint key is `default`; use the actual endpoint and DNS zone group IDs from your state and follow the [Key Vault upgrade guide](https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault/blob/v0.13.1/_header.md). The new destination is `module.landing_zone.module.key_vault[0].azapi_resource.private_dns_zone_groups["default"]`. The guide also covers locks and cross-tenant role assignments.

The [Application Insights upgrade guide](https://github.com/Azure/terraform-azurerm-avm-res-insights-component/blob/v0.5.0/_header.md) describes its temporary unknown outputs and lock considerations.

### Other output changes

The `container_registry.resource` output is no longer available; use the child module's discrete outputs such as `container_registry.login_server`, `container_registry.name`, and `container_registry.resource_id`. The `web_apps` child outputs no longer include `deployment_slot_locks`, `resource_lock`, or `resource_private_endpoints`; use `private_endpoints` for the supported private-endpoint output. The `web_apps` output is sensitive because the upgraded child module marks its resource output sensitive.

## Features

- **App Service Hosting**: Deploy App Service Plans (Linux, Windows, or Windows Managed Instance) or App Service Environments v3 (ASEv3) for isolated workloads. Supports multiple web apps with independent configuration, deployment slots, and managed identities.
- **Ingress & Load Balancing**: Choose between Azure Front Door (Premium with WAF) or Application Gateway (WAF v2) for secure, scalable ingress. Includes automatic backend pool and origin group configuration from your web apps.
- **Private Networking**: Virtual network with purpose-built subnets for App Service integration, private endpoints, bastion, and application gateway. Supports hub-spoke peering and Azure Landing Zone (ALZ) route table integration.
- **Private DNS**: Automatic private DNS zone creation and virtual network linking for App Service (`privatelink.azurewebsites.net`), Key Vault, Storage, and Container Registry.
- **Security**: Private endpoints for all supported resources, Key Vault for secrets management, WAF policies, network ACLs, RBAC role assignments, and managed identities (system and user-assigned).
- **Observability**: Application Insights with Log Analytics workspace integration, per-resource diagnostic settings, and support for ALZ policy-driven diagnostics (DINE).
- **Container Support**: Azure Container Registry (Premium with zone redundancy) for Linux and Windows container web apps, with automatic private endpoint and DNS configuration.
- **Storage**: Storage account with blob containers and file shares, firewall rules, and private endpoint support.
- **Bastion**: Azure Bastion Host for secure remote access with copy/paste, file copy, IP connect, and tunneling capabilities.
- **Bring-Your-Own Resources**: Most components accept an existing resource ID, allowing you to integrate with pre-existing infrastructure (App Service Plan, VNet, Key Vault, Container Registry, Storage Account, and more).
- **Naming**: Built-in naming module generates consistent, compliant Azure resource names with customizable overrides.
- **ALZ Integration**: First-class support for Azure Landing Zone patterns, including hub-spoke peering, centralized routing via a hub virtual appliance, policy-driven DNS zones, and DINE diagnostic settings.
