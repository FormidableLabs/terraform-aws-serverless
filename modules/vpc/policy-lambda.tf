###############################################################################
# Policy: Lambda Execution
# ------------------------
# Enhanced support for VPC for SLS-built-in Lambda execution role.
###############################################################################
resource "aws_iam_policy" "lambda_execution" {
  name   = "${local.tf_service_name}-${local.stage}-lambda-vpc"
  path   = "/"
  policy = "${data.aws_iam_policy_document.lambda_execution.json}"
}

data "aws_iam_policy_document" "lambda_execution" {
  statement {
    # Create network interfaces for deployed lambdas.
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    # Must be wildcard:
    # - https://iam.cloudonaut.io/reference/ec2.html
    # - https://docs.aws.amazon.com/AWSEC2/latest/APIReference/ec2-api-permissions.html
    resources = [
      "*",
    ]
  }
}
