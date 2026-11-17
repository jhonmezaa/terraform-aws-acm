# Complete Example

Creates several ACM certificates from a single module call:

- `wildcard`: DNS validated, `primary_domain` + `*.primary_domain` + `*.api.primary_domain`, RSA_2048
- `ec-cert`: DNS validated, `secure.primary_domain` with an `EC_prime256v1` key
- `email-validated`: EMAIL validated `mail.primary_domain`, validation emails sent to the `primary_domain` addresses (`validation_options`), without waiting
- `cloudfront`: certificate pinned to `us-east-1` (per-certificate `region`) with an explicit `Name` tag
- `multi-zone` (only when `secondary_domain` is set): one certificate whose SANs live in a second hosted zone (`zones`)

## Usage

```bash
terraform init
terraform plan -var="primary_domain=example.com"
terraform apply -var="primary_domain=example.com" -var="secondary_domain=example.org"
```

Public Route53 hosted zones for `primary_domain` (and `secondary_domain`, when set) must already exist.

## Inputs

| Name               | Description                                      | Type          | Default            | Required |
| ------------------ | ------------------------------------------------ | ------------- | ------------------ | -------- |
| `aws_region`       | AWS region where resources will be created       | `string`      | `"us-east-1"`      | no       |
| `account_name`     | Account name for resource naming                 | `string`      | `"prod"`           | no       |
| `project_name`     | Project name for resource naming                 | `string`      | `"platform"`       | no       |
| `primary_domain`   | Primary domain name for ACM certificates         | `string`      | -                  | yes      |
| `secondary_domain` | Secondary domain for the multi-zone certificate  | `string`      | `null`             | no       |
| `tags`             | Tags applied to all certificates (`tags_common`) | `map(string)` | see `variables.tf` | no       |

## Outputs

| Name                       | Description                                |
| -------------------------- | ------------------------------------------ |
| `certificate_arns`         | Map of all certificate ARNs                |
| `certificate_statuses`     | Map of all certificate statuses            |
| `certificate_domain_names` | Map of all certificate domain names        |
| `validation_record_fqdns`  | Map of DNS validation record FQDNs         |
| `certificate_names`        | Map of certificate Name tags               |
| `distinct_domain_names`    | Map of distinct domain names per certificate |
