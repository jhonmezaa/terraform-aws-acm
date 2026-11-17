# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.2.0] - 2026-11-17

### Added

- `tags_common` variable (project tagging convention); `tags` is kept as a deprecated alias merged after it
- Per-certificate `name` attribute to set an explicit `Name` tag
- Per-certificate `region` attribute (AWS provider v6 `region` argument) applied to the certificate, imported certificate and validation waiter, e.g. `us-east-1` for CloudFront. The `Name` tag uses that region's prefix
- Private certificates issued by AWS Private CA: `certificate_authority_arn` with `validation_method = "NONE"`
- `export` option (`ENABLED`/`DISABLED`) for exportable certificates
- `validation_options` map (domain => validation domain) for EMAIL validation
- `zones` map (domain => Route53 zone ID) for certificates whose domains live in several hosted zones
- `validation_record_fqdns` to pass externally managed DNS validation records to the validation waiter
- Outputs `certificate_names`, `distinct_domain_names` and `validation_domains`
- Region prefixes for `ap-southeast-5`, `ap-southeast-6`, `ap-southeast-7`, `ap-east-2` and `mx-central-1`
- README for each example

### Changed

- Variable validation error messages translated to Spanish (project convention)
- `Name` and `ManagedBy` tags are now applied last, so they can no longer be overridden through `tags`/`tags_common`/certificate `tags` (use the certificate `name` attribute instead)
- Example version files renamed from `0-versions.tf` to `versions.tf`; examples now require AWS provider `~> 6.4`
- README rewritten: `source` uses `github.com/jhonmezaa/terraform-aws-acm//acm?ref=<tag>`, inputs/outputs match the code, and the import example now sets `is_import = true`

### Fixed

- New validations: imported certificates require `certificate_body` and `private_key`; DNS validation with Route53 records requires a zone (`zone_id` or `zones`) for every domain, instead of failing later with a missing `zone_id` on `aws_route53_record`

### Deprecated

- `tags` variable: use `tags_common`

### Upgrade notes

- The minimum AWS provider version is now `>= 6.4` (first release supporting `options.export` on `aws_acm_certificate`)
- If you set a `Name` tag through `tags` or a certificate's `tags`, it is now replaced by the generated name (in-place tag update, no recreation). Set the certificate `name` attribute to keep a custom value
- No resource is recreated: certificate keys, Route53 record keys and the generated names are unchanged

## [v1.1.5] - 2026-10-27

### Changed

- Normalize CHANGELOG format: preamble moved to the top, all headings use `## [vX.Y.Z] - YYYY-MM-DD`, entries sorted by version (newest first)
- Add missing CHANGELOG entries for v1.1.0 and v1.1.1, reconstructed from git history

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
