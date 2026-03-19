variable "container_registry_docker_builds" {
  type = map(object({
    dockerfile_path = string
    source_location = string
    image_names     = list(string)
    platform = optional(object({
      os           = optional(string, "Linux")
      architecture = optional(string, "amd64")
    }), {})
  }))
  default     = {}
  description = "(Optional) A map of Docker builds to run in the Container Registry using ACR Tasks. Each entry triggers a build from a Dockerfile at the specified source location."
  nullable    = false
}

variable "container_registry_image_imports" {
  type = map(object({
    source_registry_uri = string
    source_image        = string
    image_names         = list(string)
    mode                = optional(string, "Force")
  }))
  default     = {}
  description = "(Optional) A map of container images to import into the Container Registry from external registries."
  nullable    = false
}
