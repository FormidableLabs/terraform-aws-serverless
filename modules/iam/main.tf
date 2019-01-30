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
resource "aws_iam_group" "developer" {
  name = "${local.tf_service_name}-${var.stage}-developer"
}

resource "aws_iam_group" "ci" {
  name = "${local.tf_service_name}-${var.stage}-ci"
}
