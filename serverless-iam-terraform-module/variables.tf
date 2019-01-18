// AWS
variable "region" {
  description = "The deploy target region in AWS"
  default     = "us-east-1"
}

variable "iam_region" {
  description = "The IAM region restriction for permissions (defaults to 'any region')."
  default     = "*"
}

// Service definition
// `${stack_prefix}${service_name}-${environment}`
variable "stack_prefix" {
  description = "Short prefix for stack identification"
  default     = "tf-"
}

variable "service_name" {
  description = "The unique name of this service / stack"
}

variable "environment" {
  description = "The stage/environment (e.g. dev/staging/prod) to deploy to"
  default     = "development"
}

// Serverless stack information (to synchronize with).
// TODO: SUGGEST BEST PRACTICE?
variable "sls_service_name" {
  description = "The service name from Serverless configuration"
}
