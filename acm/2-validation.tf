# =============================================================================
# DNS Validation - Route53 Records
# =============================================================================

resource "aws_route53_record" "validation" {
  for_each = local.dns_validation_records

  zone_id = each.value.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  ttl     = var.certificates[each.value.cert_key].dns_ttl

  records = [each.value.resource_record_value]

  allow_overwrite = var.certificates[each.value.cert_key].validation_allow_overwrite

  depends_on = [aws_acm_certificate.this]
}

# =============================================================================
# Certificate Validation Waiter
# =============================================================================

resource "aws_acm_certificate_validation" "this" {
  for_each = local.certificates_to_validate

  certificate_arn = aws_acm_certificate.this[each.key].arn

  validation_record_fqdns = each.value.validation_method == "DNS" && each.value.zone_id != null && each.value.create_route53_records ? [
    for k, v in aws_route53_record.validation : v.fqdn
    if v.zone_id == each.value.zone_id || startswith(k, "${each.key}/")
  ] : null

  timeouts {
    create = each.value.validation_timeout
  }

  depends_on = [aws_route53_record.validation]
}
