# Terraform AWS ACM Module

Production-ready Terraform module for creating and managing AWS ACM (Certificate Manager) certificates with DNS and email validation support.

## Features

- **Multiple Certificates**: Create multiple certificates via a single `certificates` map using `for_each` pattern
- **DNS Validation**: Automatic Route53 DNS validation record creation
- **Email Validation**: Support for email-based certificate validation
- **Wildcard Certificates**: Full support for wildcard domains (e.g., `*.example.com`)
- **Subject Alternative Names**: Multiple SANs per certificate for multi-domain coverage
- **Key Algorithm Options**: RSA_2048, EC_prime256v1, EC_secp384r1, EC_secp521r1
- **Certificate Transparency**: Configurable CT logging preference
- **Certificate Import**: Import existing certificates with private key, body, and chain
- **Validation Waiter**: Configurable timeout to wait for certificate validation
- **Regional Support**: Automatic region prefix mapping for 29 AWS regions
- **Input Validation**: Comprehensive variable validations for naming and configuration
- **Best Practices**: Follows AWS security best practices and Terraform conventions

## Usage

### Single Certificate with DNS Validation

```hcl
module "acm" {
  source = "./acm"

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

  tags = {
    Environment = "Production"
  }
}
```

### Multiple Certificates

```hcl
module "acm" {
  source = "./acm"

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
      domain_name   = "secure.example.com"
      key_algorithm = "EC_prime256v1"
      validation_method = "DNS"
      zone_id           = "Z1234567890"
    }

    # Email validated certificate
    email-cert = {
      domain_name         = "mail.example.com"
      validation_method   = "EMAIL"
      wait_for_validation = false
    }
  }
}
```

### Import Existing Certificate

```hcl
module "acm" {
  source = "./acm"

  account_name = "prod"
  project_name = "legacy"

  certificates = {
    imported = {
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
  source = "./acm"

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

| Name               | Description                                        | Type          | Default | Required |
|--------------------|----------------------------------------------------|---------------|---------|----------|
| `create`           | Whether to create ACM certificate resources        | `bool`        | `true`  | no       |
| `account_name`     | Account name for resource naming (1-32 chars, lowercase, numbers, hyphens) | `string` | - | yes |
| `project_name`     | Project name for resource naming (1-32 chars, lowercase, numbers, hyphens) | `string` | - | yes |
| `region_prefix`    | Region prefix for naming (auto-derived if not set) | `string`      | `null`  | no       |
| `use_region_prefix`| Whether to include region prefix in resource names | `bool`        | `true`  | no       |
| `tags`             | Additional tags to apply to all certificates       | `map(string)` | `{}`    | no       |

### Certificates

| Name           | Description                                 | Type              | Default | Required |
|----------------|---------------------------------------------|-------------------|---------|----------|
| `certificates` | Map of ACM certificates to create or import | `map(object({...}))` | `{}`    | no       |

#### Certificate Object Attributes

| Attribute                  | Description                                              | Type           | Default      |
|----------------------------|----------------------------------------------------------|----------------|--------------|
| `domain_name`              | Primary domain name for the certificate                 | `string`       | **required** |
| `subject_alternative_names`| Additional domain names (SANs)                          | `list(string)` | `[]`         |
| `validation_method`        | Validation method: `DNS` or `EMAIL`                     | `string`       | `"DNS"`      |
| `zone_id`                  | Route53 hosted zone ID for DNS validation               | `string`       | `null`       |
| `create_route53_records`   | Whether to create Route53 DNS validation records        | `bool`         | `true`       |
| `key_algorithm`            | Key algorithm: `RSA_2048`, `EC_prime256v1`, etc.        | `string`       | `"RSA_2048"` |
| `transparency_logging`     | Enable certificate transparency logging                 | `bool`         | `true`       |
| `wait_for_validation`      | Wait for certificate validation to complete             | `bool`         | `true`       |
| `validation_timeout`       | Timeout for validation completion                       | `string`       | `"45m"`      |
| `validation_allow_overwrite`| Allow overwriting existing Route53 validation records  | `bool`         | `true`       |
| `dns_ttl`                  | TTL for DNS validation records                          | `number`       | `60`         |
| `certificate_body`         | PEM-encoded certificate body (for import)               | `string`       | `null`       |
| `private_key`              | PEM-encoded private key (for import)                    | `string`       | `null`       |
| `certificate_chain`        | PEM-encoded certificate chain (for import)              | `string`       | `null`       |
| `tags`                     | Additional tags for this specific certificate           | `map(string)`  | `{}`         |

## Outputs

| Name                                   | Description                                                    |
|----------------------------------------|----------------------------------------------------------------|
| `certificate_arns`                     | Map of certificate ARNs (validated or imported)                |
| `certificate_statuses`                 | Map of certificate statuses                                    |
| `certificate_domain_names`             | Map of certificate primary domain names                        |
| `certificate_domain_validation_options`| Map of domain validation options (for external DNS validation) |
| `certificate_validation_emails`        | Map of validation email addresses (EMAIL validation only)      |
| `validation_route53_record_fqdns`      | Map of Route53 validation record FQDNs                         |

## Requirements

| Name      | Version |
|-----------|---------|
| terraform | ~> 1.0  |
| aws       | ~> 6.0  |

## Key Algorithm Options

| Algorithm       | Description                     | Use Case                          |
|-----------------|---------------------------------|-----------------------------------|
| `RSA_2048`      | RSA 2048-bit (default)          | Broadest compatibility            |
| `EC_prime256v1` | ECDSA P-256                     | Better performance, modern stacks |
| `EC_secp384r1`  | ECDSA P-384                     | Higher security requirements      |
| `EC_secp521r1`  | ECDSA P-521                     | Maximum security                  |

## Examples

See the [examples](./examples) directory for complete usage examples:

- [Basic](./examples/basic) - Single certificate with DNS validation and wildcard SAN
- [Complete](./examples/complete) - Multiple certificates with different algorithms, validation methods, and configurations

## Certificate Naming

By default, certificates are named:
```
{region_prefix}-acm-{account_name}-{project_name}-{key}
```

Example: `ause1-acm-prod-webapp-main`

When `use_region_prefix = false`:
```
acm-{account_name}-{project_name}-{key}
```

## Region Prefixes

The module automatically determines region prefixes for resource naming. Supports 29 AWS regions:

### US Regions
| Region    | Prefix |
|-----------|--------|
| us-east-1 | ause1  |
| us-east-2 | ause2  |
| us-west-1 | ausw1  |
| us-west-2 | ausw2  |

### EU Regions
| Region       | Prefix |
|--------------|--------|
| eu-west-1    | euwe1  |
| eu-west-2    | euwe2  |
| eu-west-3    | euwe3  |
| eu-central-1 | euce1  |
| eu-central-2 | euce2  |
| eu-north-1   | euno1  |
| eu-south-1   | euso1  |
| eu-south-2   | euso2  |

### AP Regions
| Region          | Prefix |
|-----------------|--------|
| ap-southeast-1  | apse1  |
| ap-southeast-2  | apse2  |
| ap-southeast-3  | apse3  |
| ap-southeast-4  | apse4  |
| ap-northeast-1  | apne1  |
| ap-northeast-2  | apne2  |
| ap-northeast-3  | apne3  |
| ap-south-1      | apso1  |
| ap-south-2      | apso2  |
| ap-east-1       | apea1  |

### Other Regions
| Region       | Prefix | Geographic Area |
|--------------|--------|-----------------|
| sa-east-1    | saea1  | South America   |
| ca-central-1 | cace1  | Canada          |
| ca-west-1    | cawe1  | Canada          |
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
