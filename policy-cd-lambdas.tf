###############################################################################
# Policy: Create/Delete Lambdas
###############################################################################
resource "aws_iam_policy" "cd_lambdas" {
  name   = "${local.tf_service_name}-${local.stage}-cd-lambdas"
  path   = "/"
  policy = data.aws_iam_policy_document.cd_lambdas.json
}

data "aws_iam_policy_document" "cd_lambdas" {
  # Lambda: Create, delete the serverless Lambda.
  statement {
    actions = [
      "lambda:GetEventSourceMapping",
      "lambda:ListEventSourceMappings",
      "lambda:ListFunctions",
      "lambda:ListTags",
      "lambda:TagResource",
      "lambda:UntagResource",
    ]

    # Necessary wildcards
    # https://iam.cloudonaut.io/reference/lambda.html
    # https://docs.aws.amazon.com/lambda/latest/dg/lambda-api-permissions-ref.html
    resources = [
      "*",
    ]
  }

  statement {
    # Note: `lambda:CreateFunction` now supports function ARNs!
    # https://docs.aws.amazon.com/lambda/latest/dg/lambda-api-permissions-ref.html
    actions = [
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
    ]

    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    resources = [
      local.sls_lambda_arn,
    ]
  }

  # IAM: Integrate Lambda roles.
  statement {
    actions = [
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
    ]

    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    resources = [
      local.lambda_role_iam_arn,
    ]
  }

  # Logs (`sls logs`)
  # - Need "all" ARN for `logs:DescribeLogGroups` in creating deleted Lambda.
  statement {
    actions = [
      "logs:DescribeLogGroups",
    ]

    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    resources = [
      local.sls_log_stream_all_arn,
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:PutLogEvents",
    ]

    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    resources = [
      local.sls_log_stream_arn,
    ]
  }
}

