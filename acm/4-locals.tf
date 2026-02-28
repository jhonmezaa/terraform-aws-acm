locals {
  # =============================================================================
  # Region Prefix Mapping
  # =============================================================================

  region_prefix_map = {
    # US Regions
    "us-east-1" = "ause1"
    "us-east-2" = "ause2"
    "us-west-1" = "ausw1"
    "us-west-2" = "ausw2"
    # EU Regions
    "eu-west-1"    = "euwe1"
    "eu-west-2"    = "euwe2"
    "eu-west-3"    = "euwe3"
    "eu-central-1" = "euce1"
    "eu-central-2" = "euce2"
    "eu-north-1"   = "euno1"
    "eu-south-1"   = "euso1"
    "eu-south-2"   = "euso2"
    # AP Regions
    "ap-southeast-1" = "apse1"
    "ap-southeast-2" = "apse2"
    "ap-southeast-3" = "apse3"
    "ap-southeast-4" = "apse4"
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-northeast-3" = "apne3"
    "ap-south-1"     = "apso1"
    "ap-south-2"     = "apso2"
    "ap-east-1"      = "apea1"
    # SA Regions
    "sa-east-1" = "saea1"
    # CA Regions
    "ca-central-1" = "cace1"
    "ca-west-1"    = "cawe1"
    # ME Regions
    "me-south-1"   = "meso1"
    "me-central-1" = "mece1"
    # AF Regions
    "af-south-1" = "afso1"
    # IL Regions
    "il-central-1" = "ilce1"
  }

  region_prefix = var.region_prefix != null ? var.region_prefix : lookup(
    local.region_prefix_map,
    data.aws_region.current.id,
    data.aws_region.current.id
  )

  # Name prefix: includes region prefix with trailing dash, or empty string
  name_prefix = var.use_region_prefix ? "${local.region_prefix}-" : ""

  # =============================================================================
  # Certificate Processing
  # =============================================================================

  # Filter certificates that should be created (not imported)
  create_certificates = var.create ? {
    for k, v in var.certificates : k => v
    if !v.is_import
  } : {}

  # Filter certificates that should be imported
  import_certificates = var.create ? {
    for k, v in var.certificates : k => v
    if v.is_import
  } : {}

  # =============================================================================
  # DNS Validation Processing
  # =============================================================================

  # Pre-compute expected domain names for each certificate from input variables.
  # This ensures for_each keys are known at plan time (not derived from resource output).
  # We deduplicate by replacing wildcard prefixes (*.) since the validation record
  # for *.example.com is the same as example.com.
  dns_validation_domains = merge([
    for cert_key, cert in local.create_certificates : {
      for domain in distinct([
        for d in concat([cert.domain_name], cert.subject_alternative_names) :
        replace(d, "*.", "")
      ]) :
      "${cert_key}/${domain}" => {
        cert_key = cert_key
        zone_id  = cert.zone_id
      }
    } if cert.validation_method == "DNS" && cert.create_route53_records
  ]...)

  # dns_validation_domains is used directly in for_each (keys are statically known).
  # The actual DVO values are looked up inline in the resource using the cert_key and domain.

  # Certificates that need validation waiting
  certificates_to_validate = {
    for k, v in local.create_certificates : k => v
    if v.wait_for_validation && v.validation_method != null
  }
}
