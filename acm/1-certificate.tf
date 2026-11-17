# =============================================================================
# ACM Certificate Resources
# =============================================================================

# ACM Certificate - Created (DNS or Email validation, or private CA)
resource "aws_acm_certificate" "this" {
  for_each = local.create_certificates

  region                    = each.value.region
  domain_name               = each.value.domain_name
  subject_alternative_names = each.value.subject_alternative_names
  validation_method         = each.value.validation_method == "NONE" ? null : each.value.validation_method
  key_algorithm             = each.value.key_algorithm
  certificate_authority_arn = each.value.certificate_authority_arn

  options {
    certificate_transparency_logging_preference = each.value.transparency_logging ? "ENABLED" : "DISABLED"
    export                                      = each.value.export
  }

  dynamic "validation_option" {
    for_each = each.value.validation_options

    content {
      domain_name       = validation_option.key
      validation_domain = validation_option.value
    }
  }

  tags = merge(
    local.tags_common,
    each.value.tags,
    {
      Name      = local.certificate_names[each.key]
      ManagedBy = "Terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ACM Certificate - Imported (existing certificate)
resource "aws_acm_certificate" "imported" {
  for_each = local.import_certificates

  region            = each.value.region
  certificate_body  = each.value.certificate_body
  private_key       = each.value.private_key
  certificate_chain = each.value.certificate_chain

  tags = merge(
    local.tags_common,
    each.value.tags,
    {
      Name      = local.certificate_names[each.key]
      ManagedBy = "Terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
