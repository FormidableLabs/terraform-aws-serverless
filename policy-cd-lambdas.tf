###############################################################################
# Policy: Create/Delete Lambdas
###############################################################################
resource "aws_iam_policy" "cd_lambdas" {
  name   = "${local.tf_service_name}-${local.stage}-cd-lambdas"
  path   = "/"
  policy = "${data.aws_iam_policy_document.cd_lambdas.json}"
}

data "aws_iam_policy_document" "cd_lambdas" {
  # Lambda: Create, delete the serverless Lambda.
  statement {
    actions = [
      "lambda:CreateFunction",
      "lambda:GetEventSourceMapping",
      "lambda:ListEventSourceMappings",
      "lambda:ListFunctions",
    ]

    # Necessary wildcards
    # https://iam.cloudonaut.io/reference/lambda
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "lambda:DeleteFunction",
    ]

    resources = [
      "${local.sls_lambda_arn}",
    ]
  }

  # IAM: Integrate Lambda roles.
  statement {
    actions = [
      "iam:PutRolePolicy",
    ]

    resources = [
      "${local.sls_lambda_role_arn}",
    ]
  }

  # Logs (`sls logs`)
  # - Need "all" ARN for `logs:DescribeLogGroups` in creating deleted Lambda.
  statement {
    actions = [
      "logs:DescribeLogGroups",
    ]

    resources = [
      "${local.sls_log_stream_all_arn}",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:PutLogEvents",
    ]

    resources = [
      "${local.sls_log_stream_arn}",
    ]
  }
}
