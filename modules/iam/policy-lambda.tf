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
  name   = "${var.stage}-sls-${var.service_name}-lambda"
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

# IamPolicyLambdaExecution:
#     Type: AWS::IAM::ManagedPolicy
#     Properties:
#       ManagedPolicyName: !Sub "${Stage}-sls-${ServiceName}-lambda"
#       PolicyDocument:
#         Version: "2012-10-17"
#         Statement:


#         # ... everything above this point is directly from sls-generated CF. (DONE)
#         # Everything below here is custom to this role...


#         # TODO: Xray: upload traces
#         - Effect: Allow
#           Action:
#           - xray:PutTraceSegments
#           - xray:PutTelemetryRecords
#           Resource:
#           # Must be wildcard.
#           # https://docs.aws.amazon.com/IAM/latest/UserGuide/list_awsxray.html
#           # https://docs.aws.amazon.com/xray/latest/devguide/xray-permissions.html#xray-permissions-managedpolicies
#           - "*"


#         # TODO: KMS: Read keys
#         - Effect: Allow
#           Action:
#           - kms:Decrypt
#           Resource:
#           - !GetAtt KmsKey.Arn
#         # SecretsManager: Read secrets
#         - Effect: Allow
#           Action:
#           - secretsmanager:GetSecretValue
#           Resource:
#           - !Sub "arn:aws:secretsmanager:${AwsRegion}:${AWS::AccountId}:secret:${ServiceName}/${Stage}/*"

