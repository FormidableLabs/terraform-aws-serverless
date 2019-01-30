###############################################################################
# IAM Groups
#
# - `admin`: An administrator that can create, delete, develop the services.
# - `developer`: A developer that deploy an existing service.
# - `ci`: The CI service can deploy an existing service.
#
# General reference
# - https://iam.cloudonaut.io/
# - https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html
# - http://awspolicygen.s3.amazonaws.com/policygen.html
###############################################################################

# admin
resource "aws_iam_policy" "admin" {
  name   = "${local.tf_service_name}-${local.stage}-admin"
  path   = "/"
  policy = "${data.aws_iam_policy_document.admin.json}"
}

resource "aws_iam_group" "admin" {
  name = "${local.tf_service_name}-${local.stage}-admin"
}

resource "aws_iam_group_policy_attachment" "admin" {
  group      = "${aws_iam_group.admin.name}"
  policy_arn = "${aws_iam_policy.admin.arn}"
}

# developer
resource "aws_iam_group" "developer" {
  name = "${local.tf_service_name}-${local.stage}-developer"
}

# ci
resource "aws_iam_group" "ci" {
  name = "${local.tf_service_name}-${local.stage}-ci"
}
