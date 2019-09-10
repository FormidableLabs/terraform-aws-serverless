# Outputs

output "iam_group_admin_name" {
  value = "${aws_iam_group.admin.name}"
}

output "iam_group_developer_name" {
  value = "${aws_iam_group.developer.name}"
}

output "iam_group_ci_name" {
  value = "${aws_iam_group.ci.name}"
}

output "iam_policy_admin_arn" {
  value = "${aws_iam_policy.admin.arn}"
}

output "iam_policy_developer_arn" {
  value = "${aws_iam_policy.developer.arn}"
}

output "iam_policy_ci_arn" {
  value = "${aws_iam_policy.developer.arn}"
}

output "iam_policy_cd_lambdas_arn" {
  value = "${aws_iam_policy.cd_lambdas.arn}"
}

output "lambda_role_arn" {
  value = "${aws_iam_role.lambda.*.arn[0]}"
}

output "lambda_role_name" {
  value = "${aws_iam_role.lambda.*.name[0]}"
}
