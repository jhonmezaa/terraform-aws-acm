# =============================================================================
# Route53 Records Only Example
# =============================================================================
# The certificate is created in one AWS account and its DNS validation records
# are created in the Route53 hosted zone of another account (separate AWS
# providers). The second instance of the module runs in records-only mode
# (create_route53_records_only = true): it creates no certificate, only the
# Route53 records built from the first instance's domain validation options.

provider "aws" {
  region = var.aws_region
}

# Provider for the account that owns the Route53 hosted zone. Without
# dns_role_arn it uses the same credentials as the default provider.
provider "aws" {
  alias  = "dns"
  region = var.aws_region

  dynamic "assume_role" {
    for_each = var.dns_role_arn == null ? [] : [var.dns_role_arn]

    content {
      role_arn = assume_role.value
    }
  }
}

# =============================================================================
# Data Sources
# =============================================================================

data "aws_route53_zone" "this" {
  provider = aws.dns

  name         = var.domain_name
  private_zone = false
}

locals {
  subject_alternative_names = ["*.${var.domain_name}"]
}

# =============================================================================
# ACM Certificate (certificate account) - no Route53 records
# =============================================================================

module "acm" {
  source = "../../acm"

  account_name = var.account_name
  project_name = var.project_name

  certificates = {
    main = {
      domain_name               = var.domain_name
      subject_alternative_names = local.subject_alternative_names
      create_route53_records    = false
    }
  }

  # Records created by module.route53_records. Passed through this variable
  # (not var.certificates) to avoid a dependency cycle.
  external_validation_record_fqdns = {
    main = values(module.route53_records.validation_route53_record_fqdns)
  }

  tags_common = var.tags
}

# =============================================================================
# Route53 Validation Records Only (DNS account)
# =============================================================================

module "route53_records" {
  source = "../../acm"

  providers = {
    aws = aws.dns
  }

  account_name = var.account_name
  project_name = var.project_name

  certificates = {
    main = {
      # Same domains as the certificate: they define the record keys.
      domain_name                 = var.domain_name
      subject_alternative_names   = local.subject_alternative_names
      create_route53_records_only = true
      domain_validation_options   = module.acm.certificate_domain_validation_options["main"]
      zone_id                     = data.aws_route53_zone.this.zone_id
    }
  }
}
