###############################################################################
# IAM Groups
#
# - `admin`: An administrator that can create, delete, develop the services.
# - `developer`: A developer that deploy/update an existing service.
# - `ci`: The CI service can deploy/update an existing service.
#
# General reference
# - https://iam.cloudonaut.io/
# - https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html
# - http://awspolicygen.s3.amazonaws.com/policygen.html
###############################################################################

# admin
resource "aws_iam_group" "admin" {
  name = "${local.tf_service_name}-${local.stage}-${local.role_admin_name}"
}

resource "aws_iam_group_policy_attachment" "admin_admin" {
  group      = "${aws_iam_group.admin.name}"
  policy_arn = "${aws_iam_policy.admin.arn}"
}

resource "aws_iam_group_policy_attachment" "admin_cd_lambdas" {
  count      = "${local.opt_many_lambdas ? 0 : 1}"
  group      = "${aws_iam_group.admin.name}"
  policy_arn = "${aws_iam_policy.cd_lambdas.arn}"
}

resource "aws_iam_group_policy_attachment" "admin_developer" {
  group      = "${aws_iam_group.admin.name}"
  policy_arn = "${aws_iam_policy.developer.arn}"
}

# ci
resource "aws_iam_group" "ci" {
  name = "${local.tf_service_name}-${local.stage}-${local.role_ci_name}"
}

resource "aws_iam_group_policy_attachment" "ci_developer" {
  group      = "${aws_iam_group.ci.name}"
  policy_arn = "${aws_iam_policy.developer.arn}"
}

resource "aws_iam_group_policy_attachment" "ci_cd_lambdas" {
  count      = "${local.opt_many_lambdas ? 1 : 0}"
  group      = "${aws_iam_group.ci.name}"
  policy_arn = "${aws_iam_policy.cd_lambdas.arn}"
}

# developer
resource "aws_iam_group" "developer" {
  name = "${local.tf_service_name}-${local.stage}-${local.role_developer_name}"
}

resource "aws_iam_group_policy_attachment" "developer_developer" {
  group      = "${aws_iam_group.developer.name}"
  policy_arn = "${aws_iam_policy.developer.arn}"
}

resource "aws_iam_group_policy_attachment" "developer_cd_lambdas" {
  count      = "${local.opt_many_lambdas ? 1 : 0}"
  group      = "${aws_iam_group.developer.name}"
  policy_arn = "${aws_iam_policy.cd_lambdas.arn}"
}
