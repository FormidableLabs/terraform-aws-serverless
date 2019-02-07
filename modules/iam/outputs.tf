# Outputs

output "lambda_execution_role_arn" {
  value = "${aws_iam_role.lambda_execution.arn}"
}
