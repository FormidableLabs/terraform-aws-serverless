resource "aws_s3_bucket" "dummy" {
  bucket = "${var.stack_prefix}${var.service_name}-${var.environment}-dummy-delete-this"

  tags = {
    TODO_KEY = "TODO_VALUE"
  }
}
