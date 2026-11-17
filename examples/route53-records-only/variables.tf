# =============================================================================
# Variables
# =============================================================================

variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "dns_role_arn" {
  description = "ARN of the IAM role to assume in the account that owns the Route53 hosted zone. null uses the default credentials."
  type        = string
  default     = null
}

variable "account_name" {
  description = "Account name for resource naming."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string
  default     = "webapp"
}

variable "domain_name" {
  description = "Primary domain name for the ACM certificate (a public Route53 hosted zone with this name must exist in the DNS account)."
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default = {
    Environment = "Development"
    Team        = "Platform"
  }
}
