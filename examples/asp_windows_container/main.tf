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
  features {}
}

resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"
}

module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.2"

  location         = local.azure_regions[random_integer.region_index.result]
  name             = "${module.naming.resource_group.name_unique}-asp-windows-container"
  enable_telemetry = var.enable_telemetry
}

module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"

  location            = module.resource_group.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry
}

locals {
  container_registry_login_server = "${local.container_registry_name}.azurecr.io"
  container_registry_name         = module.naming.container_registry.name_unique
}

# App Service Plan - Windows Container (custom Docker image)
# Windows Containers require Premium v3 or Isolated v2 SKUs.
module "test" {
  source = "../../"

  location                            = module.resource_group.location
  parent_id                           = module.resource_group.resource_id
  app_service_plan_os_type            = "Windows"
  container_registry_name             = local.container_registry_name
  enable_telemetry                    = var.enable_telemetry
  log_analytics_workspace_resource_id = module.log_analytics_workspace.resource_id
  web_apps = {
    app1 = {
      name = module.naming.app_service.name_unique
      site_config = {
        windows_fx_version = "DOCKER|${local.container_registry_login_server}/aspnetapp:latest"
      }
      deployment_slots = {
        uat = {
          name = "uat"
          site_config = {
            windows_fx_version = "DOCKER|${local.container_registry_login_server}/aspnetapp:latest"
          }
        }
        staging = {
          name = "staging"
          site_config = {
            windows_fx_version = "DOCKER|${local.container_registry_login_server}/aspnetapp:latest"
          }
        }
      }
    }
  }
}

# Import the sample container image into the Container Registry
resource "terraform_data" "acr_import" {
  depends_on = [module.test]

  input = local.container_registry_name

  provisioner "local-exec" {
    command = "az acr import --name ${local.container_registry_name} --source mcr.microsoft.com/dotnet/samples:aspnetapp --image aspnetapp:latest --force"
  }
}
