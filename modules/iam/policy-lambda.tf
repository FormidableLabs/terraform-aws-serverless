###############################################################################
# Policy: Lambda Execution
# ------------------------
# This is an _optional_ Lambda execution role intended to replace the built-in
# serverless Lambda execution role if more flexibility/customization is needed.
#
# Some of the scenarios in this project require the use of this role (or a
# similarly privilege one) beyond what the built-in serverless role contains.
# In terms of this project, you'll likely want to use this custom role if you
# are using this project's options of:
# - `xray`
# - `kms`
# - `secretsmanager`
#
# TODO: More documentation here or in README about dependencies/integration.
###############################################################################
resource "aws_iam_policy" "lambda_execution" {
  name   = "${local.tf_service_name}-${local.stage}-lambda"
  path   = "/"
  policy = "${data.aws_iam_policy_document.lambda_execution.json}"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda_execution" {
  # Everything below is equivalent to the SLS-generated lambda execution role.
  statement {
    actions = [
      "logs:CreateLogStream",
    ]

    resources = [
      "${local.sls_log_stream_arn}",
    ]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      "${local.sls_log_stream_arn}*",
    ]
  }
}
