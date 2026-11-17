# =============================================================================
# Outputs
# =============================================================================

output "certificate_arn" {
  description = "The ARN of the validated ACM certificate."
  value       = module.acm.certificate_arns["main"]
}

output "certificate_status" {
  description = "The status of the ACM certificate."
  value       = module.acm.certificate_statuses["main"]
}

output "validation_route53_record_fqdns" {
  description = "FQDNs of the validation records created in the DNS account."
  value       = module.route53_records.validation_route53_record_fqdns
}

output "distinct_domain_names" {
  description = "Distinct domain names validated through DNS."
  value       = module.route53_records.distinct_domain_names["main"]
}
