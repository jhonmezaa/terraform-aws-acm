# =============================================================================
# Variables
# =============================================================================

variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
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
  description = "Primary domain name for the ACM certificate."
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
