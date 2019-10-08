###############################################################################
# Policy: Developer
# -----------------
# A developer role can:
# - Deploy canary functions that use CodeDeploy.
###############################################################################
resource "aws_iam_policy" "developer" {
  name   = "${local.tf_group_developer_name}-canary"
  path   = "/"
  policy = "${data.aws_iam_policy_document.developer.json}"
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
      "arn:${local.partition}:iam::${local.account_id}:role/sls-${var.service_name}-${var.iam_stage}-CodeDeployServiceRole-*"
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

    resources = [local.sls_lambda_arn]
  }
}
