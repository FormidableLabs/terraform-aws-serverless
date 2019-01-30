###############################################################################
# Policy: Admin
###############################################################################

data "aws_iam_policy_document" "admin" {
  # CloudFormation: Create the lambda service
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
      "arn:${local.partition}:cloudformation:${local.iam_region}:${local.account_id}:stack/${local.sls_service_name}-${local.stage}/*",
    ]
  }

  # TODO HERE
}

# IamPolicyAdmin:
#     Type: AWS::IAM::ManagedPolicy
#     Properties:
#       ManagedPolicyName: !Sub "aws-${ServiceName}-${Stage}-admin"
#       PolicyDocument:
#         Version: "2012-10-17"
#         Statement:

#         # CloudFormation: Create the lambda service (DONE)
#         # S3: Upload the lambda service files.
#         - Effect: Allow
#           Action:
#           - s3:CreateBucket
#           - s3:DeleteBucket
#           Resource:
#           # **NOTE**: If you have a long service name, you can end up with
#           # bucket names like:
#           # `sls-${SERVICE_NAME}-de-serverlessdeploymentbuck-47ati3in2360`
#           # ... and I'm guessing possibly **even more truncated** for a longer
#           # service name.
#           # - No region or account id allowed
#           - !Sub "arn:${AWS::Partition}:s3:::sls-${ServiceName}-*-serverlessdeployment*-*"

#         # Lambda: Create, update, delete the service.
#         - Effect: Allow
#           Action:
#           - lambda:CreateFunction
#           - lambda:GetEventSourceMapping
#           - lambda:ListEventSourceMappings
#           - lambda:ListFunctions
#           Resource:
#           # Necessary wildcards
#           # https://iam.cloudonaut.io/reference/lambda/CreateFunction.html
#           # https://iam.cloudonaut.io/reference/lambda/GetEventSourceMapping.html
#           # https://iam.cloudonaut.io/reference/lambda/ListEventSourceMappings.html
#           # https://iam.cloudonaut.io/reference/lambda/ListFunctions.html
#           - "*"
#         - Effect: Allow
#           Action:
#           - lambda:DeleteFunction
#           Resource:
#           # `sls-${ServiceName}-${Stage}-${Handler/Function Name}`
#           - !Sub "arn:${AWS::Partition}:lambda:${AwsRegion}:${AWS::AccountId}:function:sls-${ServiceName}-${Stage}-*"

#         # IAM (allow creating and use of IAM roles)
#         # - https://github.com/serverless/serverless/issues/1439#issuecomment-363383862
#         # - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html
#         - Effect: Allow
#           Action:
#           - iam:GetRole
#           - iam:CreateRole
#           - iam:DeleteRole
#           - iam:DetachRolePolicy
#           - iam:PassRole
#           - iam:PutRolePolicy
#           - iam:AttachRolePolicy
#           - iam:DeleteRolePolicy
#           Resource:
#           - !GetAtt IamRoleLambdaExecution.Arn
#           # No region allowed
#           - !Sub "arn:${AWS::Partition}:iam::${AWS::AccountId}:role/sls-${ServiceName}-${Stage}-${AwsRegion}-lambdaRole"

#         # Logs (`sls logs`)
#         - Effect: Allow
#           Action:
#           - logs:DescribeLogStreams
#           - logs:DescribeLogGroups
#           Resource:
#           # https://iam.cloudonaut.io/reference/logs.html
#           # sls deploy (create stack) needs this, doing a request to:
#           # `arn:aws:logs:REGION:ACCOUNT:log-group::log-stream:`
#           - !Sub "arn:${AWS::Partition}:logs:${AwsRegion}:${AWS::AccountId}:log-group::log-stream:"
#           # Console log drill-down needs this permission.
#           - !Sub "arn:${AWS::Partition}:logs:${AwsRegion}:${AWS::AccountId}:log-group:aws/lambda/sls-${ServiceName}-${Stage}-*:log-stream:"
#         - Effect: Allow
#           Action:
#           - logs:CreateLogGroup
#           - logs:CreateLogStream
#           - logs:DeleteLogGroup
#           - logs:PutLogEvents
#           Resource:
#            # `sls-${ServiceName}-${Stage}-${Handler/Function Name}`
#           - !Sub "arn:${AWS::Partition}:logs:${AwsRegion}:${AWS::AccountId}:log-group:/aws/lambda/sls-${ServiceName}-${Stage}-*:log-stream:"

#         # CloudWatch Events
#         # https://serverless.com/framework/docs/providers/aws/events/cloudwatch-event/
#         - Effect: Allow
#           Action:
#           - events:Put*
#           - events:Remove*
#           - events:Delete*
#           Resource:
#           - !Sub "arn:${AWS::Partition}:events:${AwsRegion}:${AWS::AccountId}:rule/sls-${ServiceName}-${Stage}"

#         # Xray: view traces
#         - Effect: Allow
#           Action:
#           - xray:BatchGetTraces
#           - xray:GetServiceGraph
#           - xray:GetTraceGraph
#           - xray:GetTraceSummaries
#           Resource:
#           # Must be wildcard.
#           # https://docs.aws.amazon.com/IAM/latest/UserGuide/list_awsxray.html
#           # https://docs.aws.amazon.com/xray/latest/devguide/xray-permissions.html#xray-permissions-managedpolicies
#           - "*"

#         # KMS: Manage keys
#         - Effect: Allow
#           Action:
#           - kms:Create*
#           - kms:Describe*
#           - kms:Enable*
#           - kms:List*
#           - kms:Put*
#           - kms:Update*
#           - kms:Revoke*
#           - kms:Disable*
#           - kms:Get*
#           - kms:Delete*
#           - kms:TagResource
#           - kms:UntagResource
#           - kms:ScheduleKeyDeletion
#           - kms:CancelKeyDeletion
#           Resource:
#           - !GetAtt KmsKey.Arn

#         # SecretsManager: Manage secrets
#         - Effect: Allow
#           Action:
#           - secretsmanager:DescribeSecret
#           - secretsmanager:List*
#           Resource:
#           # Have to wildcard listing...
#           # TODO: ... but could do conditions + tags to limit
#           # https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_identity-based-policies.html
#           - "*"
#         - Effect: Allow
#           Action:
#           - secretsmanager:CreateSecret
#           - secretsmanager:DeleteSecret
#           Resource:
#           - !Sub "arn:aws:secretsmanager:${AwsRegion}:${AWS::AccountId}:secret:${ServiceName}/${Stage}/*"

#         # CloudWatch (Needed for `sls metrics`)
#         - Effect: Allow
#           Action:
#           # Required to view graphs in other parts of the CloudWatch console and in dashboard widgets.
#           # https://iam.cloudonaut.io/reference/cloudwatch/GetMetricStatistics.html
#           - cloudwatch:GetMetricStatistics
#           Resource:
#           # `This service does not have ARNs, so "*" will be used.`
#           - "*"
