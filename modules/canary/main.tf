###############################################################################
# Canary Support
###############################################################################

resource "aws_iam_group_policy_attachment" "admin_developer" {
  count      = "${local.opt_disable_groups ? 0 : 1}"
  group      = "${local.tf_group_admin_name}"
  policy_arn = "${aws_iam_policy.developer.arn}"
}

resource "aws_iam_group_policy_attachment" "developer_developer" {
  count      = "${local.opt_disable_groups ? 0 : 1}"
  group      = "${local.tf_group_developer_name}"
  policy_arn = "${aws_iam_policy.developer.arn}"
}

resource "aws_iam_group_policy_attachment" "ci_developer" {
  count      = "${local.opt_disable_groups ? 0 : 1}"
  group      = "${local.tf_group_ci_name}"
  policy_arn = "${aws_iam_policy.developer.arn}"
}
