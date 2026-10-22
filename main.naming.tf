module "naming" {
  source = "./modules/naming"

  location                            = var.location
  enable_telemetry                    = var.enable_telemetry
  resource_name_defaults              = var.resource_name_defaults
  resource_name_environment           = var.resource_name_environment
  resource_name_sequence_start_number = var.resource_name_sequence_start_number
  resource_name_workload              = var.resource_name_workload
  web_app_keys                        = keys(var.web_apps)
  web_app_slot_keys                   = { for key, app in var.web_apps : key => keys(app.deployment_slots) }
}
