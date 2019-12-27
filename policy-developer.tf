###############################################################################
# Policy: Developer
# -----------------
# A developer role can:
# - Update the serverless application/stack
# - View logs and run various `serverless` commands
###############################################################################
resource "aws_iam_policy" "developer" {
  name   = local.tf_group_developer_name
  path   = "/"
  policy = data.aws_iam_policy_document.developer.json
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
      "cloudformation:ListChangeSets",
      "cloudformation:ListStackResources",
      "cloudformation:Get*",
      "cloudformation:UpdateStack",
      "cloudformation:DescribeStacks",
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
      local.sls_cloudformation_arn,
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

    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    resources = [
      local.sls_deploy_bucket_arn,
    ]
  }

  # IAM (`sls deploy`)
  statement {
    actions = [
      "iam:PassRole", # Assign to Lambdas
      "iam:GetRole",
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

  # Lambda Layers (`sls deploy`)
  statement {
    # Note:
    # - `DeleteLayerVersion` is needed because the old layer is deleted on update.
    actions = [
      "lambda:GetLayerVersion",
      "lambda:PublishLayerVersion",
      "lambda:DeleteLayerVersion",
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
      local.sls_layer_arn,
    ]
  }

  # API Gateway (`sls deploy`)
  statement {
    actions = [
      "apigateway:GET",
      "apigateway:PATCH",
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:DELETE",
    ]

    resources = [
      local.sls_apigw_arn,
      local.sls_apigw_tags_arn,
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
      local.sls_log_stream_arn,
      "${local.sls_log_stream_arn}*",
    ]
  }
}

