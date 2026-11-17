# =============================================================================
# Certificate Outputs
# =============================================================================

output "certificate_arns" {
  description = "Map of certificate ARNs. For validated certificates, returns the validated ARN; for imported certificates, returns the import ARN."
  value = merge(
    {
      for k, v in aws_acm_certificate_validation.this : k => v.certificate_arn
    },
    {
      for k, v in aws_acm_certificate.this : k => v.arn
      if !contains(keys(aws_acm_certificate_validation.this), k)
    },
    {
      for k, v in aws_acm_certificate.imported : k => v.arn
    }
  )
}

output "certificate_statuses" {
  description = "Map of certificate statuses."
  value = merge(
    { for k, v in aws_acm_certificate.this : k => v.status },
    { for k, v in aws_acm_certificate.imported : k => v.status }
  )
}

output "certificate_domain_names" {
  description = "Map of certificate primary domain names."
  value = merge(
    { for k, v in aws_acm_certificate.this : k => v.domain_name },
    { for k, v in aws_acm_certificate.imported : k => v.domain_name }
  )
}

output "certificate_domain_validation_options" {
  description = "Map of domain validation options for each certificate (useful for external DNS validation)."
  value = {
    for k, v in aws_acm_certificate.this : k => v.domain_validation_options
  }
}

output "certificate_validation_emails" {
  description = "Map of email addresses that received validation emails (only for EMAIL validation)."
  value = {
    for k, v in aws_acm_certificate.this : k => v.validation_emails
  }
}

output "validation_route53_record_fqdns" {
  description = "Map of Route53 validation record FQDNs."
  value = {
    for k, v in aws_route53_record.validation : k => v.fqdn
  }
}

output "distinct_domain_names" {
  description = "Map of distinct domain names (wildcard prefix removed) per created certificate, as used for DNS validation."
  value       = local.distinct_domain_names
}

output "certificate_names" {
  description = "Map of the Name tag assigned to each certificate."
  value = {
    for k, v in merge(aws_acm_certificate.this, aws_acm_certificate.imported) : k => v.tags["Name"]
  }
}

output "validation_domains" {
  description = "Map of distinct domain validation options per created certificate, with the wildcard prefix removed from domain_name. Useful to create DNS validation records outside this module when SANs contain wildcards."
  value = {
    for k, v in aws_acm_certificate.this : k => distinct([
      for dvo in v.domain_validation_options : merge(tomap(dvo), { domain_name = replace(dvo.domain_name, "*.", "") })
    ])
  }
}
