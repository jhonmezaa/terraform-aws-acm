# =============================================================================
# ACM Certificate Resources
# =============================================================================

# ACM Certificate - Created (DNS or Email validation)
resource "aws_acm_certificate" "this" {
  for_each = local.create_certificates

  domain_name               = each.value.domain_name
  subject_alternative_names = each.value.subject_alternative_names
  validation_method         = each.value.validation_method
  key_algorithm             = each.value.key_algorithm

  options {
    certificate_transparency_logging_preference = each.value.transparency_logging ? "ENABLED" : "DISABLED"
  }

  tags = merge(
    {
      Name      = "${local.name_prefix}acm-${var.account_name}-${var.project_name}-${each.key}"
      ManagedBy = "Terraform"
    },
    var.tags,
    each.value.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ACM Certificate - Imported (existing certificate)
resource "aws_acm_certificate" "imported" {
  for_each = local.import_certificates

  certificate_body  = each.value.certificate_body
  private_key       = each.value.private_key
  certificate_chain = each.value.certificate_chain

  tags = merge(
    {
      Name      = "${local.name_prefix}acm-${var.account_name}-${var.project_name}-${each.key}"
      ManagedBy = "Terraform"
    },
    var.tags,
    each.value.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}
