# Azure App Service Application Landing Zone

This module deploys a production-ready Azure App Service hosting environment with enterprise-grade networking, security, and observability. It follows the [Azure App Service Landing Zone Accelerator](https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/app-platform/app-services/landing-zone-accelerator) architecture and is built using [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/).

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
