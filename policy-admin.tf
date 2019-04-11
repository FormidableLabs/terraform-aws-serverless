###############################################################################
# Policy: Admin
# -------------
# An admin has all the privileges of a developer and can additionally:
# - Create/Delete the serverless application/stack
# - View metrics from `sls metrics`
###############################################################################
resource "aws_iam_policy" "admin" {
  name   = "${local.tf_service_name}-${local.stage}-${local.role_admin_name}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.admin.json}"
}

data "aws_iam_policy_document" "admin" {
  # CloudFormation: Allow serverless to create the service CloudFormation stack.
  statement {
    actions = [
      "cloudformation:ListStacks",
      "cloudformation:PreviewStackUpdate",
    ]

    # Necessary wildcards
    # https://iam.cloudonaut.io/reference/cloudformation
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:CreateUploadBucket",
      "cloudformation:ListChangeSets",
      "cloudformation:ListStackResources",
      "cloudformation:Get*",
      "cloudformation:DeleteStack",
    ]

    resources = [
      "${local.sls_cloudformation_arn}",
    ]
  }

  # S3: Allow serverless to upload the packaged service for deployment.
  statement {
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
    ]

    resources = [
      "${local.sls_deploy_bucket_arn}",
    ]
  }

  # Lambda: Create, update, delete the serverless Lambda.
  statement {
    actions = [
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

  # IAM: Allow the built-in serverless framework Lambda Roles to hook up to the
  # Lambda.
  # - https://github.com/serverless/serverless/issues/1439#issuecomment-363383862
  # - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html
  statement {
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DetachRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DeleteRolePolicy",
    ]

    resources = [
      "${local.sls_lambda_role_arn}",
    ]
  }

  # CloudWatch Events
  # https://serverless.com/framework/docs/providers/aws/events/cloudwatch-event/
  statement {
    actions = [
      "events:Put*",
      "events:Remove*",
      "events:Delete*",
    ]

    resources = [
      "${local.sls_events_arn}",
    ]
  }

  # CloudWatch Metrics (Needed for `sls metrics`)
  statement {
    # Required to view graphs in other parts of the CloudWatch console and in dashboard widgets.
    actions = [
      "cloudwatch:GetMetricStatistics",
    ]

    # `This service does not have ARNs, so "*" will be used.`
    # https://iam.cloudonaut.io/reference/cloudwatch/GetMetricStatistics.html
    resources = [
      "*",
    ]
  }
}
