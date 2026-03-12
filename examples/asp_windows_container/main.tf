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
  app_service_plan_os_type            = "WindowsContainer"
  container_registry_enabled          = true
  container_registry_name             = local.container_registry_name
  enable_telemetry                    = var.enable_telemetry
  log_analytics_workspace_resource_id = module.log_analytics_workspace.resource_id
  # Import a pre-built image from MCR for use in deployment slots
  container_registry_image_imports = {
    aspnetapp_imported = {
      source_registry_uri = "mcr.microsoft.com"
      source_image        = "dotnet/samples:aspnetapp-nanoserver-ltsc2022"
      image_names         = ["aspnetapp-imported:latest"]
    }
  }
  # Build a Docker image from source for use in the production slot
  container_registry_docker_builds = {
    aspnetapp_build = {
      dockerfile_path = "Dockerfile.nanoserver"
      source_location = "https://github.com/dotnet/dotnet-docker.git#main:samples/aspnetapp"
      image_names     = ["aspnetapp-build:latest"]
      platform = {
        os = "Windows"
      }
    }
  }
  web_apps = {
    app1 = {
      name = module.naming.app_service.name_unique
      site_config = {
        application_stack = {
          docker = {
            docker_image_name   = "aspnetapp-build:latest"
            docker_registry_url = "https://${local.container_registry_login_server}"
          }
        }
        # Can alternatively specify the container image using the windows_fx_version property
        #windows_fx_version = "DOCKER|${local.container_registry_login_server}/aspnetapp-build:latest"
      }
      deployment_slots = {
        uat = {
          name = "uat"
          site_config = {
            application_stack = {
              docker = {
                docker_image_name   = "aspnetapp-imported:latest"
                docker_registry_url = "https://${local.container_registry_login_server}"
              }
            }
          }
        }
        staging = {
          name = "staging"
          site_config = {
            application_stack = {
              docker = {
                docker_image_name   = "aspnetapp-imported:latest"
                docker_registry_url = "https://${local.container_registry_login_server}"
              }
            }
          }
        }
      }
    }
  }
}
