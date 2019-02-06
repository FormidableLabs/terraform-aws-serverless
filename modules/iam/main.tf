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
  name = "${local.tf_service_name}-${local.stage}-admin"
}

resource "aws_iam_group_policy_attachment" "admin_admin" {
  group      = "${aws_iam_group.admin.name}"
  policy_arn = "${aws_iam_policy.admin.arn}"
}

resource "aws_iam_group_policy_attachment" "admin_developer" {
  group      = "${aws_iam_group.admin.name}"
  policy_arn = "${aws_iam_policy.developer.arn}"
}

# ci
resource "aws_iam_group" "ci" {
  name = "${local.tf_service_name}-${local.stage}-ci"
}

resource "aws_iam_group_policy_attachment" "ci_developer" {
  group      = "${aws_iam_group.ci.name}"
  policy_arn = "${aws_iam_policy.developer.arn}"
}

# developer
resource "aws_iam_group" "developer" {
  name = "${local.tf_service_name}-${local.stage}-developer"
}

resource "aws_iam_group_policy_attachment" "developer_developer" {
  group      = "${aws_iam_group.developer.name}"
  policy_arn = "${aws_iam_policy.developer.arn}"
}

# Optional lambda role
resource "aws_iam_role" "lambda_execution" {
  name               = "${local.tf_lambda_role_name}"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role_policy.json}"
  tags               = "${local.tags}"
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = "${aws_iam_role.lambda_execution.name}"
  policy_arn = "${aws_iam_policy.lambda_execution.arn}"
}
