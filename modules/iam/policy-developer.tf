###############################################################################
# Policy: Developer
# -----------------
# A developer role can:
# - Update the serverless application/stack
# - View logs and run various `serverless` commands
###############################################################################
resource "aws_iam_policy" "developer" {
  name   = "${local.tf_service_name}-${local.stage}-developer"
  path   = "/"
  policy = "${data.aws_iam_policy_document.developer.json}"
}

data "aws_iam_policy_document" "developer" {
  # CloudFormation (`sls deploy`)
  statement {
    actions = [
      "cloudformation:ValidateTemplate",
    ]

    # Only allows wildcard.
    # https://iam.cloudonaut.io/reference/cloudformation/ValidateTemplate.html
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStackResource",
      "cloudformation:DescribeStackResources",
      "cloudformation:UpdateStack",
      "cloudformation:DescribeStacks",
    ]

    resources = [
      "${local.sls_cloudformation_arn}",
    ]
  }

  # S3 (`sls deploy`)
  statement {
    actions = [
      "s3:ListBucketVersions",
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]

    resources = [
      "${local.sls_deploy_bucket_arn}",
    ]
  }

  # IAM (`sls deploy`)
  statement {
    actions = [
      "iam:PassRole", # Assign to Lambdas
      "iam:GetRole",
    ]

    resources = [
      # Support both serverless + our custom enhanced Lambda execution roles.
      "${local.sls_lambda_role_arn}",

      "${aws_iam_role.lambda_execution.arn}",
    ]
  }

  # Lambda (`sls deploy`)
  statement {
    # Note:
    # - `UpdateEventSourceMapping`: We don't include, but not it has a very
    #   differently structured ARN if we later add it. See, e.g.
    #   https://iam.cloudonaut.io/reference/lambda/UpdateEventSourceMapping.html
    actions = [
      "lambda:GetAlias",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:GetPolicy",
      "lambda:ListAliases",
      "lambda:ListVersionsByFunction",
      "lambda:AddPermission",
      "lambda:CreateAlias",
      "lambda:InvokeFunction",
      "lambda:PublishVersion",
      "lambda:RemovePermission",
      "lambda:Update*",
    ]

    resources = [
      "${local.sls_lambda_arn}",
    ]
  }

  # API Gateway (`sls deploy`)
  statement {
    actions = [
      "apigateway:GET",
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:DELETE",
    ]

    resources = [
      "${local.sls_apigw_arn}",
    ]
  }

  # Logs (`sls logs`)
  statement {
    actions = [
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:FilterLogEvents",
      "logs:GetLogEvents",
    ]

    # Note: Need trailing `*` in `log-stream:*` to allow viewing specific logs in AWS console.
    # https://iam.cloudonaut.io/reference/logs.html
    resources = [
      "${local.sls_log_stream_arn}*",
    ]
  }
}
