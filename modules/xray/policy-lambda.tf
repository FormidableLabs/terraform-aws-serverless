###############################################################################
# Policy: Lambda Execution
# ------------------------
# Enhanced support for Xray for SLS-built-in Lambda execution role.
###############################################################################
resource "aws_iam_policy" "lambda_execution" {
  name   = "${local.tf_service_name}-${local.stage}-lambda-xray"
  path   = "/"
  policy = "${data.aws_iam_policy_document.lambda_execution.json}"
}

data "aws_iam_policy_document" "lambda_execution" {
  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
    ]

    # Must be wildcard.
    # https://docs.aws.amazon.com/IAM/latest/UserGuide/list_awsx-ray.html
    # https://docs.aws.amazon.com/xray/latest/devguide/xray-permissions.html#xray-permissions-managedpolicies
    resources = [
      "*",
    ]
  }
}
