variable "resource_name_defaults" {
  type = map(string)
  default = {
    # Single-instance resources (supports hyphens)
    virtual_network                                 = "vnet-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    app_service_environment                         = "ase-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    app_service_plan                                = "asp-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    application_insights                            = "ai-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    bastion_host                                    = "bas-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    application_gateway                             = "agw-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    application_gateway_public_ip                   = "pip-agw-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    application_gateway_public_ip_domain_name_label = "app-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${unique_name}-$${sequence}"
    front_door                                      = "afd-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    alz_route_table                                 = "rt-alz-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    managed_identity                                = "id-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    log_analytics_workspace                         = "law-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    azure_monitor_private_link_scope                = "ampls-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    ampls_law_scoped_service                        = "ampls-law-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    ampls_appinsights_scoped_service                = "ampls-ai-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"

    # Globally unique resources (with unique_name segment)
    key_vault = "kv-$${resource_name_workload}-$${resource_name_environment}-$${sequence}-$${unique_name}"

    # No hyphens, short location, globally unique
    storage_account    = "st$${resource_name_workload}$${resource_name_environment}$${short_location}$${unique_name}$${sequence}"
    container_registry = "cr$${resource_name_workload}$${resource_name_environment}$${short_location}$${unique_name}$${sequence}"

    # VNet links
    vnet_link_web                = "vnetlink-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    vnet_link_key_vault          = "vnetlink-kv-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    vnet_link_storage_blob       = "vnetlink-blob-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    vnet_link_storage_file       = "vnetlink-file-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    vnet_link_container_registry = "vnetlink-cr-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    vnet_link_monitor            = "vnetlink-monitor-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    vnet_link_oms                = "vnetlink-oms-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    vnet_link_ods                = "vnetlink-ods-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    vnet_link_agentsvc           = "vnetlink-agentsvc-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"

    # Peering names
    peer_to_hub       = "peer-to-hub-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    peer_from_hub     = "peer-from-hub-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    alz_peer_to_hub   = "peer-to-alz-hub-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    alz_peer_from_hub = "peer-from-alz-hub-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"

    # Per web app resources (globally unique for web_app)
    web_app                       = "app-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${unique_name}-$${sequence}"
    web_app_managed_identity      = "id-app-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
    web_app_slot_managed_identity = "id-slot-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"

    # Front Door per-app components
    front_door_endpoint     = "fde-$${resource_name_workload}-$${resource_name_environment}-$${unique_name}-$${sequence}"
    front_door_origin_group = "fdog-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    front_door_origin       = "fdo-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    front_door_route        = "fdr-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"

    # Front Door single-instance, no hyphens
    front_door_waf_policy      = "wafpol$${resource_name_workload}$${resource_name_environment}$${sequence}"
    front_door_security_policy = "secpol$${resource_name_workload}$${resource_name_environment}$${sequence}"

    # Application Gateway per-app components
    application_gateway_backend_pool = "backend-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    application_gateway_http_setting = "httpsetting-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    application_gateway_listener     = "listener-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    application_gateway_probe        = "probe-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
    application_gateway_routing_rule = "rule-$${resource_name_workload}-$${resource_name_environment}-$${sequence}"
  }
  description = <<DESCRIPTION
A map of resource name templates keyed by resource type. Override individual templates to customize naming.
Templates use the `templatestring` function with these available variables:

- `resource_name_workload` - The workload name (default: "demo")
- `resource_name_environment` - The environment name (default: "dev")
- `location` - The Azure region name
- `short_location` - Abbreviated region name from the regions utility module
- `sequence` - 3-digit padded sequence number (e.g. 001)
- `unique_name` - 4-character random string for globally unique resources

Example:
```hcl
resource_name_defaults = {
  virtual_network = "vnet-$${resource_name_workload}-$${resource_name_environment}-$${location}-$${sequence}"
  storage_account = "st$${resource_name_workload}$${resource_name_environment}$${short_location}$${unique_name}$${sequence}"
}
```
DESCRIPTION
}

variable "resource_name_environment" {
  type        = string
  default     = "dev"
  description = "The environment name segment used in resource name templates."
  nullable    = false
}

variable "resource_name_sequence_start_number" {
  type        = number
  default     = 1
  description = "The starting sequence number used in resource name templates. Formatted as a 3-character string (e.g. 001). For multi-instance resources like web apps, each instance increments from this starting number."
  nullable    = false
}

variable "resource_name_workload" {
  type        = string
  default     = "demo"
  description = "The workload name segment used in resource name templates."
  nullable    = false
}
