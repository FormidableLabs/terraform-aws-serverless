###############################################################################
# Policy: Developer
# -----------------
# A developer role can:
# - Get VPC and related information.
###############################################################################
resource "aws_iam_policy" "developer" {
  name   = "${local.tf_group_developer_name}-vpc"
  path   = "/"
  policy = data.aws_iam_policy_document.developer.json
}

data "aws_iam_policy_document" "developer" {
  statement {
    # Get VPC information in order to be able to deploy serverless with `vpc:`
    # configuration references.
    actions = [
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeNetworkInterfaces",
    ]

    # Must be wildcard:
    # - https://iam.cloudonaut.io/reference/ec2.html
    # - https://docs.aws.amazon.com/AWSEC2/latest/APIReference/ec2-api-permissions.html
    resources = [
      "*",
    ]
  }
}

