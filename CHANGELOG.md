# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.1.4] - 2026-10-27

### Fixed

- Replace deprecated `data.aws_region.current.id` with `data.aws_region.current.region` (AWS provider v6)

## [v1.1.3] - 2026-10-27

### Changed

- Use minimum-only version constraints in the reusable module, per HashiCorp guidance: AWS provider `~> 6.0` -> `>= 6.0`
- Set module `required_version` to `>= 1.3` (was `~> 1.0`), the real minimum required by the use of `optional()` object attributes in variable types and the `startswith()` function (Terraform 1.3+)
- Examples (root modules) keep pessimistic constraints: `required_version` `~> 1.3` and AWS provider `~> 6.0`
- Update README requirements table

## [v1.1.2] - 2026-04-25

### Changed

- Update README documentation and CHANGELOG formatting

## [v1.1.1] - 2026-02-28

### Changed

- Update README documentation and CHANGELOG formatting

## [v1.1.0] - 2026-02-28

### Added

- `is_import` boolean field (default: `false`) in `certificates` to explicitly control the import vs create flow, avoiding unknown `for_each` keys when `certificate_body`/`private_key` are computed values

### Fixed

- Resolve `for_each` unknown key issues in DNS validation and certificate import
- Pre-compute DNS validation record keys from input variables (`domain_name` and `subject_alternative_names`) instead of deriving them from resource output, so `for_each` keys are known at plan time
- Remove `zone_id != null` check from the `dns_validation_domains` filter to prevent unknown value propagation when `zone_id` comes from another module's output
- Look up `domain_validation_options` values inline in the Route53 record resource instead of in a local, keeping `for_each` keys static

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

- Wildcard certificate support (e.g., \*.example.com)
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
