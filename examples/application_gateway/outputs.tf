output "application_gateway_url" {
  description = "The FQDN URL of the Application Gateway public IP."
  value       = module.test.application_gateway_url
}
