# =============================================================================
# Outputs
# =============================================================================

output "certificate_arns" {
  description = "Map of all certificate ARNs."
  value       = module.acm.certificate_arns
}

output "certificate_statuses" {
  description = "Map of all certificate statuses."
  value       = module.acm.certificate_statuses
}

output "certificate_domain_names" {
  description = "Map of all certificate domain names."
  value       = module.acm.certificate_domain_names
}

output "validation_record_fqdns" {
  description = "Map of DNS validation record FQDNs."
  value       = module.acm.validation_route53_record_fqdns
}
