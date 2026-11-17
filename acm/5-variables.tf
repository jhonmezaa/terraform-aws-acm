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
    error_message = "account_name debe tener entre 1 y 32 caracteres."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.account_name))
    error_message = "account_name solo puede contener letras minúsculas, números y guiones."
  }
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 32
    error_message = "project_name debe tener entre 1 y 32 caracteres."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name solo puede contener letras minúsculas, números y guiones."
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

variable "tags_common" {
  description = "Common tags applied to all certificates."
  type        = map(string)
  default     = {}
}

variable "external_validation_record_fqdns" {
  description = "Map of certificate key => FQDNs of externally managed DNS validation records, passed to the validation waiter together with each certificate's validation_record_fqdns. Separate from var.certificates so it can reference records created from this module's outputs (e.g. by a second instance of this module in records-only mode) without a dependency cycle."
  type        = map(list(string))
  default     = {}
}

variable "tags" {
  description = "(Deprecated: use tags_common) Additional tags to apply to all certificates. Merged after tags_common."
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
    - name:                      (Optional) Explicit value for the Name tag. Default: "<region_prefix>-acm-<account_name>-<project_name>-<key>".
    - region:                    (Optional) Region where the certificate is managed (AWS provider v6 `region` argument).
                                 Default: the provider region. Use "us-east-1" for CloudFront certificates.
    - subject_alternative_names: (Optional) List of additional domain names for the certificate (SANs).
    - validation_method:         (Optional) Validation method: "DNS", "EMAIL" or "NONE". Default: "DNS".
                                 Use "NONE" for private certificates issued by certificate_authority_arn.
    - certificate_authority_arn: (Optional) ARN of an AWS Private CA to issue a private certificate (requires validation_method = "NONE").
    - export:                    (Optional) Whether the certificate can be exported: "ENABLED" or "DISABLED". Default: null (AWS default, DISABLED).
                                 Exportable public certificates incur additional charges.
    - validation_options:        (Optional) Map of domain name => validation domain, used to change the domain that
                                 receives EMAIL validation messages.
    - zone_id:                   (Optional) Route53 hosted zone ID for automatic DNS validation record creation.
    - zones:                     (Optional) Map of domain name (without "*.") => Route53 zone ID for domains that live
                                 in a different hosted zone than zone_id.
    - create_route53_records:    (Optional) Whether to create Route53 DNS validation records. Default: true.
    - validation_record_fqdns:   (Optional) FQDNs of externally managed DNS validation records passed to the validation waiter.
    - create_route53_records_only: (Optional) Do not create the certificate: only create the Route53 DNS validation records of an
                                 existing certificate from domain_validation_options (e.g. with a provider for another account).
                                 Requires validation_method = "DNS". Default: false.
    - domain_validation_options: (Optional) Domain validation options of the existing certificate (records-only mode), e.g. the
                                 certificate_domain_validation_options or validation_domains output of another instance of this module.
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
    domain_name                 = string
    name                        = optional(string)
    region                      = optional(string)
    subject_alternative_names   = optional(list(string), [])
    validation_method           = optional(string, "DNS")
    certificate_authority_arn   = optional(string)
    export                      = optional(string)
    validation_options          = optional(map(string), {})
    zone_id                     = optional(string)
    zones                       = optional(map(string), {})
    create_route53_records      = optional(bool, true)
    validation_record_fqdns     = optional(list(string), [])
    create_route53_records_only = optional(bool, false)
    domain_validation_options = optional(list(object({
      domain_name           = string
      resource_record_name  = string
      resource_record_type  = string
      resource_record_value = string
    })), [])
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
      contains(["DNS", "EMAIL", "NONE"], v.validation_method)
      if !v.is_import
    ])
    error_message = "validation_method debe ser 'DNS', 'EMAIL' o 'NONE' en los certificados nuevos."
  }

  validation {
    condition = alltrue([
      for k, v in var.certificates :
      contains(["RSA_2048", "EC_prime256v1", "EC_secp384r1", "EC_secp521r1"], v.key_algorithm)
      if !v.is_import
    ])
    error_message = "key_algorithm debe ser uno de: RSA_2048, EC_prime256v1, EC_secp384r1, EC_secp521r1."
  }

  validation {
    condition = alltrue([
      for k, v in var.certificates :
      v.certificate_body != null && v.private_key != null
      if v.is_import
    ])
    error_message = "Los certificados con is_import = true requieren certificate_body y private_key."
  }

  validation {
    condition = alltrue([
      for k, v in var.certificates :
      (v.validation_method == "NONE") == (v.certificate_authority_arn != null)
      if !v.is_import
    ])
    error_message = "certificate_authority_arn (certificado privado) requiere validation_method = 'NONE', y 'NONE' solo se admite con certificate_authority_arn."
  }

  validation {
    condition = alltrue([
      for k, v in var.certificates :
      v.export == null || contains(["ENABLED", "DISABLED"], coalesce(v.export, "DISABLED"))
    ])
    error_message = "export debe ser 'ENABLED', 'DISABLED' o null."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.certificates : [
        for d in concat([v.domain_name], v.subject_alternative_names) :
        lookup(v.zones, replace(d, "*.", ""), v.zone_id) != null
      ] if !v.is_import && v.validation_method == "DNS" && (v.create_route53_records || v.create_route53_records_only)
    ]))
    error_message = "Con validation_method = 'DNS' y create_route53_records = true, cada dominio necesita zone_id o una entrada en zones."
  }

  validation {
    condition = alltrue([
      for k, v in var.certificates :
      !v.is_import && v.validation_method == "DNS"
      if v.create_route53_records_only
    ])
    error_message = "create_route53_records_only requiere validation_method = 'DNS' y no se puede combinar con is_import."
  }

  validation {
    condition = alltrue([
      for k, v in var.certificates :
      length(v.domain_validation_options) > 0
      if v.create_route53_records_only
    ])
    error_message = "create_route53_records_only requiere domain_validation_options (las opciones de validación del certificado existente)."
  }
}
