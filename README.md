# Terraform AWS ACM Module

Production-ready Terraform module for creating and managing AWS ACM (Certificate Manager) certificates with DNS validation, email validation, private CA issuance and certificate import.

## Features

- **Multiple Certificates**: Create multiple certificates via a single `certificates` map using `for_each` pattern
- **DNS Validation**: Automatic Route53 DNS validation record creation, including certificates whose domains live in several hosted zones (`zones`)
- **External DNS Validation**: Skip Route53 records and pass externally managed record FQDNs to the validation waiter (`validation_record_fqdns`)
- **Email Validation**: Email-based validation, with an optional custom validation domain (`validation_options`)
- **Private Certificates**: Issue private certificates from an AWS Private CA (`certificate_authority_arn` + `validation_method = "NONE"`)
- **Exportable Certificates**: Opt-in exportable public certificates (`export`)
- **Per-certificate Region**: Manage a certificate in a different region than the provider (e.g. `us-east-1` for CloudFront) using the AWS provider v6 `region` argument
- **Wildcard Certificates**: Full support for wildcard domains (e.g., `*.example.com`)
- **Subject Alternative Names**: Multiple SANs per certificate for multi-domain coverage
- **Key Algorithm Options**: RSA_2048, EC_prime256v1, EC_secp384r1, EC_secp521r1
- **Certificate Transparency**: Configurable CT logging preference
- **Certificate Import**: Import existing certificates with private key, body, and chain
- **Validation Waiter**: Configurable timeout to wait for certificate validation
- **Regional Support**: Automatic region prefix mapping for 34 AWS regions
- **Input Validation**: Comprehensive variable validations for naming and configuration

## Usage

### Single Certificate with DNS Validation

```hcl
module "acm" {
  source = "github.com/jhonmezaa/terraform-aws-acm//acm?ref=v1.2.0"

  account_name = "prod"
  project_name = "webapp"

  certificates = {
    main = {
      domain_name               = "example.com"
      subject_alternative_names = ["*.example.com"]
      validation_method         = "DNS"
      zone_id                   = "Z1234567890"
      wait_for_validation       = true
    }
  }

  tags_common = {
    Environment = "Production"
  }
}
```

### Multiple Certificates

```hcl
module "acm" {
  source = "github.com/jhonmezaa/terraform-aws-acm//acm?ref=v1.2.0"

  account_name = "prod"
  project_name = "platform"

  certificates = {
    # Wildcard certificate for main domain
    wildcard = {
      domain_name = "example.com"
      subject_alternative_names = [
        "*.example.com",
        "*.api.example.com",
      ]
      validation_method = "DNS"
      zone_id           = "Z1234567890"
    }

    # EC key algorithm certificate
    secure = {
      domain_name       = "secure.example.com"
      key_algorithm     = "EC_prime256v1"
      validation_method = "DNS"
      zone_id           = "Z1234567890"
    }

    # Email validated certificate, validation emails sent to admin@example.com, etc.
    email-cert = {
      domain_name       = "mail.example.com"
      validation_method = "EMAIL"
      validation_options = {
        "mail.example.com" = "example.com"
      }
      wait_for_validation = false
    }
  }
}
```

### CloudFront Certificate (us-east-1) and Multiple Hosted Zones

```hcl
module "acm" {
  source = "github.com/jhonmezaa/terraform-aws-acm//acm?ref=v1.2.0"

  account_name = "prod"
  project_name = "web"

  certificates = {
    cdn = {
      region                    = "us-east-1" # CloudFront only accepts us-east-1 certificates
      domain_name               = "example.com"
      subject_alternative_names = ["example.org", "*.example.org"]
      zone_id                   = "Z1111111111" # default zone (example.com)
      zones = {
        "example.org" = "Z2222222222" # keys are domains without "*."
      }
    }
  }
}
```

### DNS Records Managed Outside the Module

```hcl
module "acm" {
  source = "github.com/jhonmezaa/terraform-aws-acm//acm?ref=v1.2.0"

  account_name = "prod"
  project_name = "webapp"

  certificates = {
    main = {
      domain_name             = "example.com"
      create_route53_records  = false
      validation_record_fqdns = [for r in cloudflare_dns_record.validation : r.name]
    }
  }
}
```

Use the `certificate_domain_validation_options` or `validation_domains` outputs to create the records in the external DNS provider.

### Private Certificate (AWS Private CA)

```hcl
module "acm" {
  source = "github.com/jhonmezaa/terraform-aws-acm//acm?ref=v1.2.0"

  account_name = "prod"
  project_name = "internal"

  certificates = {
    internal = {
      domain_name               = "service.internal.example.com"
      validation_method         = "NONE"
      certificate_authority_arn = "arn:aws:acm-pca:us-east-1:123456789012:certificate-authority/abcd-1234"
    }
  }
}
```

### Import Existing Certificate

```hcl
module "acm" {
  source = "github.com/jhonmezaa/terraform-aws-acm//acm?ref=v1.2.0"

  account_name = "prod"
  project_name = "legacy"

  certificates = {
    imported = {
      is_import         = true
      domain_name       = "legacy.example.com"
      certificate_body  = file("certs/cert.pem")
      private_key       = file("certs/key.pem")
      certificate_chain = file("certs/chain.pem")
    }
  }
}
```

### Certificate without Region Prefix

```hcl
module "acm" {
  source = "github.com/jhonmezaa/terraform-aws-acm//acm?ref=v1.2.0"

  account_name      = "prod"
  project_name      = "webapp"
  use_region_prefix = false

  certificates = {
    main = {
      domain_name       = "example.com"
      validation_method = "DNS"
      zone_id           = "Z1234567890"
    }
  }
}
```

## Inputs

### General Configuration

| Name                | Description                                                                | Type          | Default | Required |
| ------------------- | -------------------------------------------------------------------------- | ------------- | ------- | -------- |
| `create`            | Whether to create ACM certificate resources                                | `bool`        | `true`  | no       |
| `account_name`      | Account name for resource naming (1-32 chars, lowercase, numbers, hyphens) | `string`      | -       | yes      |
| `project_name`      | Project name for resource naming (1-32 chars, lowercase, numbers, hyphens) | `string`      | -       | yes      |
| `region_prefix`     | Region prefix for naming (auto-derived if not set)                         | `string`      | `null`  | no       |
| `use_region_prefix` | Whether to include region prefix in resource names                         | `bool`        | `true`  | no       |
| `tags_common`       | Common tags applied to all certificates                                    | `map(string)` | `{}`    | no       |
| `tags`              | **Deprecated**, use `tags_common`. Merged after `tags_common`              | `map(string)` | `{}`    | no       |

### Certificates

| Name           | Description                                 | Type                 | Default | Required |
| -------------- | ------------------------------------------- | -------------------- | ------- | -------- |
| `certificates` | Map of ACM certificates to create or import | `map(object({...}))` | `{}`    | no       |

#### Certificate Object Attributes

| Attribute                    | Description                                                                                         | Type           | Default      |
| ---------------------------- | --------------------------------------------------------------------------------------------------- | -------------- | ------------ |
| `domain_name`                | Primary domain name for the certificate                                                             | `string`       | **required** |
| `name`                       | Explicit value for the `Name` tag (overrides the generated name)                                    | `string`       | `null`       |
| `region`                     | Region where the certificate is managed (default: provider region)                                  | `string`       | `null`       |
| `subject_alternative_names`  | Additional domain names (SANs)                                                                      | `list(string)` | `[]`         |
| `validation_method`          | Validation method: `DNS`, `EMAIL` or `NONE` (private CA)                                            | `string`       | `"DNS"`      |
| `certificate_authority_arn`  | AWS Private CA ARN to issue a private certificate (requires `validation_method = "NONE"`)           | `string`       | `null`       |
| `export`                     | Whether the certificate can be exported: `ENABLED` or `DISABLED` (extra charges for public certs)   | `string`       | `null`       |
| `validation_options`         | Map of domain name => validation domain for EMAIL validation                                        | `map(string)`  | `{}`         |
| `zone_id`                    | Route53 hosted zone ID for DNS validation                                                           | `string`       | `null`       |
| `zones`                      | Map of domain (without `*.`) => Route53 zone ID, for domains outside `zone_id`                      | `map(string)`  | `{}`         |
| `create_route53_records`     | Whether to create Route53 DNS validation records                                                    | `bool`         | `true`       |
| `validation_record_fqdns`    | FQDNs of externally managed DNS validation records passed to the waiter                             | `list(string)` | `[]`         |
| `key_algorithm`              | Key algorithm: `RSA_2048`, `EC_prime256v1`, `EC_secp384r1`, `EC_secp521r1`                          | `string`       | `"RSA_2048"` |
| `transparency_logging`       | Enable certificate transparency logging                                                             | `bool`         | `true`       |
| `wait_for_validation`        | Wait for certificate validation to complete                                                         | `bool`         | `true`       |
| `validation_timeout`         | Timeout for validation completion                                                                   | `string`       | `"45m"`      |
| `validation_allow_overwrite` | Allow overwriting existing Route53 validation records                                               | `bool`         | `true`       |
| `dns_ttl`                    | TTL for DNS validation records                                                                      | `number`       | `60`         |
| `is_import`                  | Import an existing certificate instead of requesting one (requires `certificate_body`/`private_key`) | `bool`         | `false`      |
| `certificate_body`           | PEM-encoded certificate body (for import)                                                           | `string`       | `null`       |
| `private_key`                | PEM-encoded private key (for import)                                                                | `string`       | `null`       |
| `certificate_chain`          | PEM-encoded certificate chain (for import)                                                          | `string`       | `null`       |
| `tags`                       | Additional tags for this specific certificate                                                       | `map(string)`  | `{}`         |

With `validation_method = "DNS"` and `create_route53_records = true`, every domain (after removing `*.`) must resolve to a zone through `zones` or `zone_id`.

## Outputs

| Name                                    | Description                                                                 |
| --------------------------------------- | --------------------------------------------------------------------------- |
| `certificate_arns`                      | Map of certificate ARNs (validated or imported)                             |
| `certificate_names`                     | Map of the `Name` tag assigned to each certificate                          |
| `certificate_statuses`                  | Map of certificate statuses                                                 |
| `certificate_domain_names`              | Map of certificate primary domain names                                     |
| `certificate_domain_validation_options` | Map of domain validation options (for external DNS validation)              |
| `certificate_validation_emails`         | Map of validation email addresses (EMAIL validation only)                   |
| `validation_route53_record_fqdns`       | Map of Route53 validation record FQDNs                                      |
| `distinct_domain_names`                 | Map of distinct domain names (wildcard removed) per created certificate     |
| `validation_domains`                    | Map of distinct domain validation options (wildcard removed) per certificate |

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.3  |
| aws       | >= 6.4  |

AWS provider `6.4` is the first release that supports `options.export` on `aws_acm_certificate`.

## Key Algorithm Options

| Algorithm       | Description            | Use Case                          |
| --------------- | ---------------------- | --------------------------------- |
| `RSA_2048`      | RSA 2048-bit (default) | Broadest compatibility            |
| `EC_prime256v1` | ECDSA P-256            | Better performance, modern stacks |
| `EC_secp384r1`  | ECDSA P-384            | Higher security requirements      |
| `EC_secp521r1`  | ECDSA P-521            | Maximum security                  |

## Examples

See the [examples](./examples) directory for complete usage examples:

- [Basic](./examples/basic) - Single certificate with DNS validation and wildcard SAN
- [Complete](./examples/complete) - Multiple certificates with different algorithms, validation methods, regions and hosted zones

## Certificate Naming

ACM certificates have no name attribute; the module sets the `Name` tag to:

```
{region_prefix}-acm-{account_name}-{project_name}-{key}
```

Example: `ause1-acm-prod-webapp-main`

When `use_region_prefix = false`:

```
acm-{account_name}-{project_name}-{key}
```

A certificate with its own `region` uses that region's prefix (unless `region_prefix` is set). Set `name` on a certificate to use an explicit value instead. Tags are merged as `tags_common` → `tags` (deprecated) → certificate `tags` → `{ Name, ManagedBy = "Terraform" }`.

## Region Prefixes

The module automatically determines region prefixes for resource naming. Supports 34 AWS regions:

### US Regions

| Region    | Prefix |
| --------- | ------ |
| us-east-1 | ause1  |
| us-east-2 | ause2  |
| us-west-1 | ausw1  |
| us-west-2 | ausw2  |

### EU Regions

| Region       | Prefix |
| ------------ | ------ |
| eu-west-1    | euwe1  |
| eu-west-2    | euwe2  |
| eu-west-3    | euwe3  |
| eu-central-1 | euce1  |
| eu-central-2 | euce2  |
| eu-north-1   | euno1  |
| eu-south-1   | euso1  |
| eu-south-2   | euso2  |

### AP Regions

| Region         | Prefix |
| -------------- | ------ |
| ap-southeast-1 | apse1  |
| ap-southeast-2 | apse2  |
| ap-southeast-3 | apse3  |
| ap-southeast-4 | apse4  |
| ap-southeast-5 | apse5  |
| ap-southeast-6 | apse6  |
| ap-southeast-7 | apse7  |
| ap-northeast-1 | apne1  |
| ap-northeast-2 | apne2  |
| ap-northeast-3 | apne3  |
| ap-south-1     | apso1  |
| ap-south-2     | apso2  |
| ap-east-1      | apea1  |
| ap-east-2      | apea2  |

### Other Regions

| Region       | Prefix | Geographic Area |
| ------------ | ------ | --------------- |
| sa-east-1    | saea1  | South America   |
| ca-central-1 | cace1  | Canada          |
| ca-west-1    | cawe1  | Canada          |
| mx-central-1 | mxce1  | Mexico          |
| me-south-1   | meso1  | Middle East     |
| me-central-1 | mece1  | Middle East     |
| af-south-1   | afso1  | Africa          |
| il-central-1 | ilce1  | Israel          |

You can override this with the `region_prefix` variable.

## License

MIT License - see [LICENSE](./LICENSE) for details.

## Author

Created and maintained by [Jhon Meza](https://github.com/jhonmezaa).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
