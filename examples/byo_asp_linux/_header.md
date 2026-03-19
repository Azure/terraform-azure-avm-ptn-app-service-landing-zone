# Bring Your Own Resources - ASP Linux

This example demonstrates using the module with pre-existing (Bring Your Own) resources: a virtual network with subnets, an App Service Plan, and a private DNS zone. The module creates only the web app, private endpoints, and Azure Front Door, wiring them into your existing infrastructure.

> **Note:** Azure Front Door can take upwards of 30 minutes to replicate globally. During that time, you may see a "Page Not Found" error when navigating to the Front Door endpoint.
