# =============================================================================
# General Configuration Variables
# =============================================================================

variable "create" {
  description = "Whether to create ACM certificate resources."
  type        = bool
  default     = true
}

variable "account_name" {
  description = "Account name for resource naming."
  type        = string

  validation {
    condition     = length(var.account_name) > 0 && length(var.account_name) <= 32
    error_message = "account_name must be between 1 and 32 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.account_name))
    error_message = "account_name can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 32
    error_message = "project_name must be between 1 and 32 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "region_prefix" {
  description = "Region prefix for naming. If not provided, will be derived from current region."
  type        = string
  default     = null
}

variable "use_region_prefix" {
  description = "Whether to include the region prefix in resource names."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all certificates."
  type        = map(string)
  default     = {}
}

# =============================================================================
# Certificates Configuration
# =============================================================================

variable "certificates" {
  description = <<-EOT
    Map of ACM certificates to create. Each key is a unique identifier for the certificate.

    Attributes:
    - domain_name:               (Required) Primary domain name for the certificate (e.g., "example.com" or "*.example.com").
    - subject_alternative_names: (Optional) List of additional domain names for the certificate (SANs).
    - validation_method:         (Optional) Validation method: "DNS" or "EMAIL". Default: "DNS".
    - zone_id:                   (Optional) Route53 hosted zone ID for automatic DNS validation record creation.
    - create_route53_records:    (Optional) Whether to create Route53 DNS validation records. Default: true.
    - key_algorithm:             (Optional) Algorithm for the certificate key pair. Default: "RSA_2048".
                                 Valid values: RSA_2048, EC_prime256v1, EC_secp384r1, EC_secp521r1.
    - transparency_logging:      (Optional) Whether to log certificate details to a transparency log. Default: true.
    - wait_for_validation:       (Optional) Whether to wait for the certificate to be validated. Default: true.
    - validation_timeout:        (Optional) Timeout for validation completion. Default: "45m".
    - validation_allow_overwrite: (Optional) Whether to allow overwriting existing Route53 validation records. Default: true.
    - dns_ttl:                   (Optional) TTL for DNS validation records. Default: 60.
    - is_import:                 (Optional) Set to true to import an existing certificate instead of creating a new one. Default: false.
                                 When true, certificate_body and private_key must be provided.
    - certificate_body:          (Optional) Certificate body for importing an existing certificate (PEM format).
    - private_key:               (Optional) Private key for importing an existing certificate (PEM format).
    - certificate_chain:         (Optional) Certificate chain for importing an existing certificate (PEM format).
    - tags:                      (Optional) Additional tags specific to this certificate.
  EOT

  type = map(object({
    domain_name                = string
    subject_alternative_names  = optional(list(string), [])
    validation_method          = optional(string, "DNS")
    zone_id                    = optional(string)
    create_route53_records     = optional(bool, true)
    key_algorithm              = optional(string, "RSA_2048")
    transparency_logging       = optional(bool, true)
    wait_for_validation        = optional(bool, true)
    validation_timeout         = optional(string, "45m")
    validation_allow_overwrite = optional(bool, true)
    dns_ttl                    = optional(number, 60)
    is_import                  = optional(bool, false)
    certificate_body           = optional(string)
    private_key                = optional(string)
    certificate_chain          = optional(string)
    tags                       = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.certificates :
      v.validation_method == null || contains(["DNS", "EMAIL"], v.validation_method)
      if !v.is_import
    ])
    error_message = "validation_method must be 'DNS' or 'EMAIL' for new certificates."
  }

  validation {
    condition = alltrue([
      for k, v in var.certificates :
      contains(["RSA_2048", "EC_prime256v1", "EC_secp384r1", "EC_secp521r1"], v.key_algorithm)
      if !v.is_import
    ])
    error_message = "key_algorithm must be one of: RSA_2048, EC_prime256v1, EC_secp384r1, EC_secp521r1."
  }
}
