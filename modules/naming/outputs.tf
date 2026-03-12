output "resource_names" {
  description = "Computed resource names from templates."
  value = {
    # Single-instance resource names
    virtual_network               = local.virtual_network_name
    app_service_environment       = local.app_service_environment_name
    app_service_plan              = local.app_service_plan_name
    application_insights          = local.application_insights_name
    bastion_host                  = local.bastion_host_name
    application_gateway           = local.application_gateway_name
    application_gateway_public_ip = local.application_gateway_public_ip_name
    front_door                    = local.front_door_name
    alz_route_table               = local.alz_route_table_name
    managed_identity              = local.managed_identity_name
    key_vault                     = local.key_vault_name
    storage_account               = local.storage_account_name
    container_registry            = local.container_registry_name
    vnet_link_web                 = local.vnet_link_web_name
    vnet_link_key_vault           = local.vnet_link_key_vault_name
    vnet_link_storage_blob        = local.vnet_link_storage_blob_name
    vnet_link_storage_file        = local.vnet_link_storage_file_name
    vnet_link_container_registry  = local.vnet_link_container_registry_name
    peer_to_hub                   = local.peer_to_hub_name
    peer_from_hub                 = local.peer_from_hub_name
    alz_peer_to_hub               = local.alz_peer_to_hub_name
    alz_peer_from_hub             = local.alz_peer_from_hub_name
    front_door_waf_policy         = local.front_door_waf_policy_name
    front_door_security_policy    = local.front_door_security_policy_name

    # Per-web-app resource names (maps keyed by web app key)
    web_app                          = local.web_app_names
    web_app_managed_identity         = local.web_app_managed_identity_names
    front_door_endpoint              = local.front_door_endpoint_names
    front_door_origin_group          = local.front_door_origin_group_names
    front_door_origin                = local.front_door_origin_names
    front_door_route                 = local.front_door_route_names
    application_gateway_backend_pool = local.application_gateway_backend_pool_names
    application_gateway_http_setting = local.application_gateway_http_setting_names
    application_gateway_listener     = local.application_gateway_listener_names
    application_gateway_probe        = local.application_gateway_probe_names
    application_gateway_routing_rule = local.application_gateway_routing_rule_names

    # Per-slot resource names (maps keyed by "${app_key}-${slot_key}")
    web_app_slot_managed_identity = local.web_app_slot_managed_identity_names
  }
}
