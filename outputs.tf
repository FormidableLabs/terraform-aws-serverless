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
