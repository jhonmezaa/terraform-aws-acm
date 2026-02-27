# =============================================================================
# Basic ACM Certificate Example
# =============================================================================
# This example demonstrates creating a single ACM certificate with DNS
# validation using Route53.

provider "aws" {
  region = var.aws_region
}

# =============================================================================
# Data Sources
# =============================================================================

data "aws_route53_zone" "this" {
  name         = var.domain_name
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
    main = {
      domain_name               = var.domain_name
      subject_alternative_names = ["*.${var.domain_name}"]
      validation_method         = "DNS"
      zone_id                   = data.aws_route53_zone.this.zone_id
      wait_for_validation       = true
    }
  }

  tags = var.tags
}
