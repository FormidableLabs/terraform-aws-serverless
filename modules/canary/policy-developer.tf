###############################################################################
# Policy: Developer
# -----------------
# A developer role can:
# - Deploy canary functions that use CodeDeploy.
###############################################################################
resource "aws_iam_policy" "developer" {
  name   = "${local.tf_group_developer_name}-canary"
  path   = "/"
  policy = data.aws_iam_policy_document.developer.json
}

locals {
  # The canary plugin generates a nasty suffix for the CodeDeploy project name.
  # Since this is already keyed by service name and stage, wildcard it.
  codedeploy_application_name = "sls-${local.service_name}-${local.iam_stage}-*"
}

data "aws_iam_policy_document" "developer" {
  statement {
    actions = [
      "iam:GetRole",
      "iam:PassRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
    ]

    resources = [
      "arn:${local.partition}:iam::${local.account_id}:role/sls-${local.service_name}-${local.iam_stage}-CodeDeployServiceRole-*",
    ]
  }

  statement {
    actions = [
      "codedeploy:CreateApplication",
      "codedeploy:DeleteApplication",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:RegisterApplicationRevision",
      "codedeploy:UpdateApplication",
    ]

    resources = [
      "arn:${local.iam_partition}:codedeploy:${local.iam_region}:${local.iam_account_id}:application:${local.codedeploy_application_name}-*",
    ]
  }

  statement {
    actions = [
      "codedeploy:ContinueDeployment",
      "codedeploy:CreateDeploymentGroup",
      "codedeploy:CreateDeployment",
      "codedeploy:DeleteDeploymentGroup",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentGroup",
      "codedeploy:ListDeploymentGroups",
      "codedeploy:ListDeployments",
      "codedeploy:StopDeployment",
      "codedeploy:UpdateDeploymentGroup",
    ]

    resources = [
      "arn:${local.iam_partition}:codedeploy:${local.iam_region}:${local.iam_account_id}:deploymentgroup:${local.codedeploy_application_name}-*/sls-${local.service_name}-${local.iam_stage}-*LambdaFunctionDeploymentGroup-*",
    ]
  }

  # Allow access to all default CodeDeploy deployment configs
  statement {
    actions = ["codedeploy:GetDeploymentConfig"]

    resources = ["arn:${local.iam_partition}:codedeploy:${local.iam_region}:${local.iam_account_id}:deploymentconfig:CodeDeployDefault.*"]
  }

  statement {
    actions = ["lambda:DeleteAlias"]

    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    resources = [local.sls_lambda_arn]
  }
}

