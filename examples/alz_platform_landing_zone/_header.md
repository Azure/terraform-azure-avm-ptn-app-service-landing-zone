# ALZ Platform Landing Zone Integration

This example deploys the module integrated with an Azure Landing Zone (ALZ) hub-spoke topology. It creates a hub virtual network with a Basic SKU Azure Firewall, then deploys the App Service Landing Zone as a spoke peered to the hub with route table egress through the firewall.

**Note:** The `alz_platform_landing_zone_private_dns_zone_mode_enabled` flag is left as `false` in this example because the ALZ policy for automatic private DNS zone attachment is not deployed. In a real ALZ environment with the policy deployed, set this to `true` to skip deploying private DNS zones and rely on the central DNS zone managed by policy.

> **Note:** Azure Front Door can take upwards of 30 minutes to replicate globally. During that time, you may see a "Page Not Found" error when navigating to the Front Door endpoint.
