# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.0] - 2026-02-27

### Added

#### Core ACM Features
- ACM certificate creation with DNS or Email validation
- Certificate import support (existing certificates with private key, body, and chain)
- Multiple certificates via `for_each` pattern using `certificates` map variable
- Automatic Route53 DNS validation record creation
- Configurable validation timeout with waiter resource
- Certificate transparency logging control

#### Key Algorithm Support
- RSA_2048 (default)
- EC_prime256v1 (ECDSA P-256)
- EC_secp384r1 (ECDSA P-384)
- EC_secp521r1 (ECDSA P-521)

#### Wildcard and SAN Support
- Wildcard certificate support (e.g., *.example.com)
- Subject Alternative Names (SANs) for multi-domain certificates
- Automatic deduplication of wildcard DNS validation records

#### Naming Convention
- Automatic region prefix mapping for 29 AWS regions
- Consistent naming: `{region_prefix}-acm-{account_name}-{project_name}-{key}`
- Optional region prefix via `use_region_prefix` variable
- Custom region prefix override support

#### Variable Validations
- `account_name`: 1-32 characters, lowercase letters, numbers, and hyphens
- `project_name`: 1-32 characters, lowercase letters, numbers, and hyphens
- `validation_method`: Must be DNS or EMAIL
- `key_algorithm`: Must be a valid ACM key algorithm
- `certificate_body` and `private_key`: Must be provided together for imports

#### Outputs (6 total)
- Certificate ARNs (validated or imported)
- Certificate statuses
- Certificate domain names
- Domain validation options (for external DNS)
- Validation emails (for EMAIL validation)
- Route53 validation record FQDNs

#### Examples
- **basic**: Single certificate with DNS validation and wildcard SAN
- **complete**: Multiple certificates with different algorithms, validation methods, and configurations

#### Documentation
- Comprehensive README with usage examples
- Complete variable documentation with descriptions
- Output variable documentation
- terraform.tfvars.example files for all examples

### Technical Details

- **Breaking Changes**: None (initial release)
- **Terraform Version**: ~> 1.0
- **AWS Provider Version**: ~> 6.0

[v1.0.0]: https://github.com/jhonmezaa/terraform-aws-acm/releases/tag/v1.0.0
