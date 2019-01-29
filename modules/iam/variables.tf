# TODO: Move these variables up to root?

# AWS
variable "region" {
  description = "The deploy target region in AWS"
  default     = "us-east-1"
}

variable "iam_region" {
  description = "The IAM region restriction for permissions (defaults to 'any region')."
  default     = "*"
}

# Our custom stack / environment
variable "environment" {
  description = "The stage/environment to deploy to. Suggest: `sandbox`, `development`, `staging`, `production`."
  default     = "development"
}

variable "service_name" {
  description = "Name of service / application"
}

# Terraform service name.
# _Note_: Defaults are performed in local variables.
variable "tf_service_name" {
  description = "The unique name of service for Terraform resources. Defaults to: `tf-SERVICE_NAME`."
  default     = ""
}

# Serverless version (to synchronize with).
# _Note_: Defaults are performed in local variables.
variable "sls_service_name" {
  description = "The service name from Serverless configuration. Defaults to: `sls-SERVICE_NAME`."
  default     = ""
}

locals {
  tf_service_name = "${var.tf_service_name != "" ? var.tf_service_name : "tf-${var.service_name}"}"
  sls_service_name = "${var.sls_service_name != "" ? var.sls_service_name : "sls-${var.service_name}"}"
}
