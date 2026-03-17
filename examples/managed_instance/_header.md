# App Service Managed Instance (Windows)

This example deploys the module with a Windows Managed Instance App Service Plan using the convenience variables (`managed_instance_install_scripts`, `managed_instance_registry_adapters`, `managed_instance_storage_mounts`). The module automatically creates and configures the storage account, key vault, managed identity, containers, blobs, file shares, secrets, and private endpoints — the user only needs to specify the high-level intent.

> **Note:** Azure Front Door can take upwards of 30 minutes to replicate globally. During that time, you may see a "Page Not Found" error when navigating to the Front Door endpoint.
