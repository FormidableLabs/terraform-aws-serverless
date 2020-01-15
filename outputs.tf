# Outputs

# Use the dummy list trick to fix conditional outputs.
# This is only an issue in Terraform versions earlier than 0.12.x.
# See https://github.com/hashicorp/terraform/issues/9858#issuecomment-386431631
locals {
  empty_list = [""]
}

output "iam_group_admin_name" {
  value = element(concat(local.empty_list, aws_iam_group.admin.*.name), 1)
}

output "iam_group_developer_name" {
  value = element(concat(local.empty_list, aws_iam_group.developer.*.name), 1)
}

output "iam_group_ci_name" {
  value = element(concat(local.empty_list, aws_iam_group.ci.*.name), 1)
}

output "iam_policy_admin_arn" {
  value = aws_iam_policy.admin.arn
}

output "iam_policy_developer_arn" {
  value = aws_iam_policy.developer.arn
}

output "iam_policy_ci_arn" {
  value = aws_iam_policy.developer.arn
}

output "iam_policy_cd_lambdas_arn" {
  value = aws_iam_policy.cd_lambdas.arn
}

output "lambda_role_arn" {
  value = element(concat(local.empty_list, aws_iam_role.lambda.*.arn), 1)
}

output "lambda_role_name" {
  value = element(concat(local.empty_list, aws_iam_role.lambda.*.name), 1)
}

