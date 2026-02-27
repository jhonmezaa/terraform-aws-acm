# =============================================================================
# Complete ACM Certificate Example
# =============================================================================
# This example demonstrates multiple certificates with different configurations:
# - DNS validated certificate with wildcard SAN
# - DNS validated certificate with multiple SANs
# - Email validated certificate
# - Certificate with EC key algorithm

provider "aws" {
  region = var.aws_region
}

# =============================================================================
# Data Sources
# =============================================================================

data "aws_route53_zone" "primary" {
  name         = var.primary_domain
  private_zone = false
}

data "aws_route53_zone" "secondary" {
  count = var.secondary_domain != null ? 1 : 0

  name         = var.secondary_domain
  private_zone = false
}

# =============================================================================
# ACM Certificate Module
# =============================================================================

module "acm" {
  source = "../../acm"

  account_name = var.account_name
  project_name = var.project_name

  certificates = {
    # Primary wildcard certificate with DNS validation
    wildcard = {
      domain_name = var.primary_domain
      subject_alternative_names = [
        "*.${var.primary_domain}",
        "*.api.${var.primary_domain}",
      ]
      validation_method    = "DNS"
      zone_id              = data.aws_route53_zone.primary.zone_id
      key_algorithm        = "RSA_2048"
      transparency_logging = true
      wait_for_validation  = true
      validation_timeout   = "45m"
      tags = {
        CertificateType = "wildcard"
      }
    }

    # EC key algorithm certificate
    ec-cert = {
      domain_name = "secure.${var.primary_domain}"
      subject_alternative_names = [
        "*.secure.${var.primary_domain}",
      ]
      validation_method    = "DNS"
      zone_id              = data.aws_route53_zone.primary.zone_id
      key_algorithm        = "EC_prime256v1"
      transparency_logging = true
      wait_for_validation  = true
      tags = {
        CertificateType = "ec-key"
      }
    }

    # Email validated certificate (no Route53 records created)
    email-validated = {
      domain_name         = var.primary_domain
      validation_method   = "EMAIL"
      wait_for_validation = false
      tags = {
        CertificateType = "email-validation"
      }
    }
  }

  tags = var.tags
}
