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
  count = local.opt_disable_groups ? 0 : 1
  name  = local.tf_group_admin_name
}

resource "aws_iam_group_policy_attachment" "admin_admin" {
  count      = local.opt_disable_groups ? 0 : 1
  group      = element(aws_iam_group.admin.*.name, count.index)
  policy_arn = aws_iam_policy.admin.arn
}

resource "aws_iam_group_policy_attachment" "admin_cd_lambdas" {
  count      = local.opt_disable_groups ? 0 : 1
  group      = element(aws_iam_group.admin.*.name, count.index)
  policy_arn = aws_iam_policy.cd_lambdas.arn
}

resource "aws_iam_group_policy_attachment" "admin_developer" {
  count      = local.opt_disable_groups ? 0 : 1
  group      = element(aws_iam_group.admin.*.name, count.index)
  policy_arn = aws_iam_policy.developer.arn
}

# ci
resource "aws_iam_group" "ci" {
  count = local.opt_disable_groups ? 0 : 1
  name  = local.tf_group_ci_name
}

resource "aws_iam_group_policy_attachment" "ci_developer" {
  count      = local.opt_disable_groups ? 0 : 1
  group      = element(aws_iam_group.ci.*.name, count.index)
  policy_arn = aws_iam_policy.developer.arn
}

resource "aws_iam_group_policy_attachment" "ci_cd_lambdas" {
  count      = false == local.opt_disable_groups && local.opt_many_lambdas ? 1 : 0
  group      = element(aws_iam_group.ci.*.name, count.index)
  policy_arn = aws_iam_policy.cd_lambdas.arn
}

# developer
resource "aws_iam_group" "developer" {
  count = local.opt_disable_groups ? 0 : 1
  name  = local.tf_group_developer_name
}

resource "aws_iam_group_policy_attachment" "developer_developer" {
  count      = local.opt_disable_groups ? 0 : 1
  group      = element(aws_iam_group.developer.*.name, count.index)
  policy_arn = aws_iam_policy.developer.arn
}

resource "aws_iam_group_policy_attachment" "developer_cd_lambdas" {
  count      = false == local.opt_disable_groups && local.opt_many_lambdas ? 1 : 0
  group      = element(aws_iam_group.developer.*.name, count.index)
  policy_arn = aws_iam_policy.cd_lambdas.arn
}

