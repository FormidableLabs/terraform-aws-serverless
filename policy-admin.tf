###############################################################################
# Policy: Admin
# -------------
# An admin has all the privileges of a developer and can additionally:
# - Create/Delete the serverless application/stack
# - View metrics from `sls metrics`
###############################################################################
resource "aws_iam_policy" "admin" {
  name   = local.tf_group_admin_name
  path   = "/"
  policy = data.aws_iam_policy_document.admin.json
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
      "cloudformation:DeleteStack",
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

  # S3: Allow serverless to upload the packaged service for deployment.
  statement {
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutBucketPolicy",
      "s3:GetEncryptionConfiguration",
      "s3:PutEncryptionConfiguration",
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

  # CloudWatch Events
  # https://serverless.com/framework/docs/providers/aws/events/cloudwatch-event/
  statement {
    actions = [
      "events:Put*",
      "events:Remove*",
      "events:Delete*",
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
      local.sls_events_arn,
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

