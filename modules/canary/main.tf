###############################################################################
# Canary Support
###############################################################################

resource "aws_iam_group_policy_attachment" "admin_developer" {
  group      = "${local.tf_group_admin_name}"
  policy_arn = "${aws_iam_policy.developer.arn}"
}

resource "aws_iam_group_policy_attachment" "developer_developer" {
  group      = "${local.tf_group_developer_name}"
  policy_arn = "${aws_iam_policy.developer.arn}"
}

resource "aws_iam_group_policy_attachment" "ci_developer" {
  group      = "${local.tf_group_ci_name}"
  policy_arn = "${aws_iam_policy.developer.arn}"
}
