# =============================================================================
# Outputs
# =============================================================================

output "certificate_arn" {
  description = "The ARN of the created ACM certificate."
  value       = module.acm.certificate_arns["main"]
}

output "certificate_status" {
  description = "The status of the created ACM certificate."
  value       = module.acm.certificate_statuses["main"]
}

output "certificate_domain_name" {
  description = "The domain name of the created ACM certificate."
  value       = module.acm.certificate_domain_names["main"]
}
