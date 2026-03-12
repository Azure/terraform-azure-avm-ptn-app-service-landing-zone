locals {
  container_registry_id = var.container_registry_resource_id != null ? var.container_registry_resource_id : (
    local.container_registry_effectively_enabled ? module.container_registry[0].resource_id : null
  )
  container_registry_images_enabled = var.container_registry_resource_id != null || local.container_registry_effectively_enabled
}

resource "azapi_resource_action" "container_registry_image_import" {
  for_each = local.container_registry_images_enabled ? var.container_registry_image_imports : {}

  type        = "Microsoft.ContainerRegistry/registries@2023-11-01-preview"
  resource_id = local.container_registry_id
  action      = "importImage"

  body = {
    source = {
      registryUri = each.value.source_registry_uri
      sourceImage = each.value.source_image
    }
    targetTags = each.value.image_names
    mode       = each.value.mode
  }
}

resource "azapi_resource_action" "container_registry_docker_build" {
  for_each = local.container_registry_images_enabled ? var.container_registry_docker_builds : {}

  type        = "Microsoft.ContainerRegistry/registries@2019-06-01-preview"
  resource_id = local.container_registry_id
  action      = "scheduleRun"

  body = {
    type           = "DockerBuildRequest"
    dockerFilePath = each.value.dockerfile_path
    imageNames     = each.value.image_names
    sourceLocation = each.value.source_location
    isPushEnabled  = true
    noCache        = false
    platform = {
      os           = each.value.platform.os
      architecture = each.value.platform.architecture
    }
  }

  timeouts {
    create = "30m"
  }
}
