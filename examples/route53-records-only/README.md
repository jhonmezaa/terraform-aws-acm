# Route53 Records Only Example

Creates an ACM certificate for `domain_name` (with a `*.domain_name` SAN) in the account of the default provider, and creates its DNS validation records in the Route53 hosted zone of **another account** (provider `aws.dns`, assuming `dns_role_arn`). Equivalent to the official module's `create_certificate = false` + `create_route53_records_only = true`.

- `module.acm` creates the certificate with `create_route53_records = false` and waits for validation using the record FQDNs passed in `external_validation_record_fqdns`.
- `module.route53_records` runs in records-only mode (`create_route53_records_only = true`): it creates no certificate, only the Route53 records built from `domain_validation_options` (output `certificate_domain_validation_options` of `module.acm`).

The FQDNs go through the module-level `external_validation_record_fqdns` variable, not through `certificates`, so there is no dependency cycle between both module instances.

## Usage

```bash
terraform init
terraform plan -var="domain_name=example.com" -var="dns_role_arn=arn:aws:iam::111111111111:role/route53-acm-validation"
terraform apply -var="domain_name=example.com" -var="dns_role_arn=arn:aws:iam::111111111111:role/route53-acm-validation"
```

A public Route53 hosted zone named `domain_name` must exist in the DNS account. Without `dns_role_arn` both providers use the same credentials.

## Inputs

| Name           | Description                                                        | Type          | Default            | Required |
| -------------- | ------------------------------------------------------------------ | ------------- | ------------------ | -------- |
| `aws_region`   | AWS region where resources will be created                         | `string`      | `"us-east-1"`      | no       |
| `dns_role_arn` | IAM role to assume in the account that owns the Route53 zone       | `string`      | `null`             | no       |
| `account_name` | Account name for resource naming                                   | `string`      | `"dev"`            | no       |
| `project_name` | Project name for resource naming                                   | `string`      | `"webapp"`         | no       |
| `domain_name`  | Primary domain name for the ACM certificate                        | `string`      | -                  | yes      |
| `tags`         | Tags applied to the certificate (`tags_common`)                    | `map(string)` | see `variables.tf` | no       |

## Outputs

| Name                              | Description                                           |
| --------------------------------- | ----------------------------------------------------- |
| `certificate_arn`                 | The ARN of the validated ACM certificate              |
| `certificate_status`              | The status of the ACM certificate                     |
| `validation_route53_record_fqdns` | FQDNs of the validation records in the DNS account    |
| `distinct_domain_names`           | Distinct domain names validated through DNS           |
