# Outputs

# TODO: Want these?
# output "admin_group_name" {
#   value = "${aws_iam_group.admin.name}"
# }

# output "ci_group_name" {
#   value = "${aws_iam_group.ci.name}"
# }

# output "developer_group_name" {
#   value = "${aws_iam_group.developer.name}"
# }

# output "lambda_execution_role_name" {
#   value = "${aws_iam_role.lambda_execution.name}"
# }

output "lambda_execution_role_arn" {
  value = "${aws_iam_role.lambda_execution.arn}"
}
