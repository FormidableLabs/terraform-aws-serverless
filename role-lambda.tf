locals {
  # If the user provides a custom lambda role, don't create the default role,
  # but still attach the policies that we'd attach to the default role.
  # This means we should check `var.lambda_role_name` **not** `local.`.
  count = "${var.lambda_role_name != "" ? 0 : 1}"
}

resource "aws_iam_role" "lambda" {
  count              = "${local.count}"
  name               = "tf-${local.service_name}-${local.stage}-lambda-execution"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume.json}"
  tags               = "${local.tags}"
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "lambda" {
  name   = "tf-${local.service_name}-${local.stage}-lambda-execution"
  policy = "${data.aws_iam_policy_document.lambda.json}"
}

# Replicate the log permissions from the default Serverless role.
data "aws_iam_policy_document" "lambda" {
  statement {
    actions   = ["logs:CreateLogStream"]
    resources = ["arn:${local.iam_partition}:logs:${local.iam_region}:${local.iam_account_id}:log-group:/aws/lambda/${local.sls_service_name}-${local.iam_stage}*:*"]
  }

  statement {
    actions   = ["logs:PutLogEvents"]
    resources = ["arn:${local.iam_partition}:logs:${local.iam_region}:${local.iam_account_id}:log-group:/aws/lambda/${local.sls_service_name}-${local.iam_stage}*:*:*"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = "${local.lambda_role_name}"
  policy_arn = "${aws_iam_policy.lambda.arn}"
}

# Use a small CloudFormation stack to expose outputs for
# consumption in Serverless. (There are _many_ ways to do this, we just
# like this as there's no local disk state needed to deploy.)
#
# _Note_: CF **requires** 1+ `Resources`, so we throw in the SSM param of the
# role ARN because it's small and we need "something". It's otherwise unused.
#
# See: https://theburningmonk.com/2019/03/making-terraform-and-serverless-framework-work-together/
resource "aws_cloudformation_stack" "outputs_lambda_role" {
  # Only create the stack if we create the default role
  count = "${local.count}"
  name  = "tf-${local.service_name}-${local.stage}-outputs-lambda-role"

  template_body = <<STACK
Resources:
  LambdaExecutionRoleArn:
    Type: AWS::SSM::Parameter
    Properties:
      Name: "tf-${local.service_name}-${local.stage}-LambdaExecutionRoleArn"
      Value: "${aws_iam_role.lambda.*.arn[count.index]}"
      Type: String

Outputs:
  LambdaExecutionRoleArn:
    Description: "The ARN of the lambda execution role for Serverless to apply"
    Value: "${aws_iam_role.lambda.*.arn[count.index]}"
    Export:
      Name: "tf-${local.service_name}-${local.stage}-LambdaExecutionRoleArn"

STACK

  tags = "${local.tags}"
}
