# Basic Example

Creates a single ACM certificate for `domain_name` with a `*.domain_name` SAN, validated through DNS records in the existing public Route53 hosted zone of the same name, and waits for the validation to complete.

## Usage

```bash
terraform init
terraform plan -var="domain_name=example.com"
terraform apply -var="domain_name=example.com"
```

A public Route53 hosted zone named `domain_name` must already exist in the account.

## Inputs

| Name           | Description                                 | Type          | Default       | Required |
| -------------- | ------------------------------------------- | ------------- | ------------- | -------- |
| `aws_region`   | AWS region where resources will be created  | `string`      | `"us-east-1"` | no       |
| `account_name` | Account name for resource naming            | `string`      | `"dev"`       | no       |
| `project_name` | Project name for resource naming            | `string`      | `"webapp"`    | no       |
| `domain_name`  | Primary domain name for the ACM certificate | `string`      | -             | yes      |
| `tags`         | Tags applied to the certificate (`tags_common`) | `map(string)` | see `variables.tf` | no |

## Outputs

| Name                      | Description                                 |
| ------------------------- | ------------------------------------------- |
| `certificate_arn`         | The ARN of the created ACM certificate      |
| `certificate_status`      | The status of the created ACM certificate   |
| `certificate_domain_name` | The domain name of the created certificate  |
