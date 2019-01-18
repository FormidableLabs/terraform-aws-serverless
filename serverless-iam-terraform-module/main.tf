provider "aws" {
  region  = "${var.region}"
  version = "~> 1.19"
  bucket = "${var.stack_prefix}${var.service_name}-${var.environment}-terraform-state"
  dynamodb_table = "${var.stack_prefix}${var.service_name}-${var.environment}-terraform-locks"
}
