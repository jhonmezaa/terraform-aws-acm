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
  default     = "prod"
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string
  default     = "platform"
}

variable "primary_domain" {
  description = "Primary domain name for ACM certificates."
  type        = string
}

variable "secondary_domain" {
  description = "Secondary domain name for multi-domain certificate."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default = {
    Environment = "Production"
    Team        = "Platform"
  }
}
