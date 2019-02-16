###############################################################################
# XRay Support
###############################################################################

# SLS-built-in lambda role
resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = "${local.sls_lambda_role_name}"
  policy_arn = "${aws_iam_policy.lambda_execution.arn}"
}
