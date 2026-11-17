# =============================================================================
# DNS Validation - Route53 Records
# =============================================================================

locals {
  # Domain validation options per certificate: from the certificate created by
  # this module, or from the input in records-only mode.
  domain_validation_options = merge(
    { for k, v in aws_acm_certificate.this : k => v.domain_validation_options },
    { for k, v in local.records_only_certificates : k => v.domain_validation_options }
  )
}

resource "aws_route53_record" "validation" {
  for_each = local.dns_validation_domains

  zone_id = each.value.zone_id
  name = [
    for dvo in local.domain_validation_options[each.value.cert_key] :
    dvo.resource_record_name
    if replace(dvo.domain_name, "*.", "") == split("/", each.key)[1]
  ][0]
  type = [
    for dvo in local.domain_validation_options[each.value.cert_key] :
    dvo.resource_record_type
    if replace(dvo.domain_name, "*.", "") == split("/", each.key)[1]
  ][0]
  ttl = var.certificates[each.value.cert_key].dns_ttl

  records = [[
    for dvo in local.domain_validation_options[each.value.cert_key] :
    dvo.resource_record_value
    if replace(dvo.domain_name, "*.", "") == split("/", each.key)[1]
  ][0]]

  allow_overwrite = var.certificates[each.value.cert_key].validation_allow_overwrite

  depends_on = [aws_acm_certificate.this]
}

locals {
  # Validation FQDNs per certificate (list length is known at plan time).
  validation_fqdns = {
    for cert_key, cert in local.certificates_to_validate : cert_key => concat(
      [for k, v in aws_route53_record.validation : v.fqdn if startswith(k, "${cert_key}/")],
      cert.validation_record_fqdns,
      lookup(var.external_validation_record_fqdns, cert_key, [])
    )
  }
}

# =============================================================================
# Certificate Validation Waiter
# =============================================================================

resource "aws_acm_certificate_validation" "this" {
  for_each = local.certificates_to_validate

  region          = each.value.region
  certificate_arn = aws_acm_certificate.this[each.key].arn

  # Route53 records created by this module plus externally managed records.
  # null when there are none (EMAIL validation, or DNS records managed elsewhere
  # without explicit FQDNs), so the waiter only polls the certificate status.
  validation_record_fqdns = each.value.validation_method == "DNS" && length(local.validation_fqdns[each.key]) > 0 ? local.validation_fqdns[each.key] : null

  timeouts {
    create = each.value.validation_timeout
  }

  depends_on = [aws_route53_record.validation]
}
