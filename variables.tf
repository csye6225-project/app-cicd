variable "region" {
  type        = string
  description = "Region"
  default     = "us-east-1"
}

variable "aws_access_key" {
  type        = string
  description = "Access Key"
}

variable "aws_secret_key" {
  type        = string
  description = "Secret Key"
}

variable "s3_bucket_arn" {
  type        = string
  description = "The default bucket arn"
}

variable "account_id" {
  type        = string
  description = "Account ID Number"
}

variable "aws_iam_username" {
  type        = string
  description = "ghactions-app username"
  default     = "ghactions-app"
}