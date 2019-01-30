###############################################################################
# Policy: Developer
# -----------------
# A developer role can:
# - Update the serverless application/stack
# - View logs and run various `serverless` commands
###############################################################################
resource "aws_iam_policy" "developer" {
  name   = "${local.tf_service_name}-${local.stage}-developer"
  path   = "/"
  policy = "${data.aws_iam_policy_document.developer.json}"
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
      "cloudformation:UpdateStack",
      "cloudformation:DescribeStacks",
    ]

    resources = [
      "arn:${local.partition}:cloudformation:${local.iam_region}:${local.account_id}:stack/${local.sls_service_name}-${local.stage}/*",
    ]
  }
}

# IamPolicyDeveloper:
#     Type: AWS::IAM::ManagedPolicy
#     Properties:
#       ManagedPolicyName: !Sub "aws-${ServiceName}-${Stage}-developer"
#       PolicyDocument:
#         Version: "2012-10-17"
#         Statement:


#         # CloudFormation (`sls deploy`). (DONE)


#         # S3 (`sls deploy`)
#         - Effect: Allow
#           Action:
#           - s3:ListBucketVersions
#           - s3:PutObject
#           - s3:GetObject
#           - s3:ListBucket
#           - s3:DeleteObject
#           Resource:
#           # - No region or account id allowed
#           - !Sub "arn:${AWS::Partition}:s3:::sls-${ServiceName}-*-serverlessdeployment*-*"


#         # IAM (`sls deploy`)
#         - Effect: Allow
#           Action:
#           - iam:GetRole
#           Resource:
#           - !GetAtt IamRoleLambdaExecution.Arn
#           # No region allowed
#           - !Sub "arn:${AWS::Partition}:iam::${AWS::AccountId}:role/sls-${ServiceName}-${Stage}-${AwsRegion}-lambdaRole"


#         # Lambda (`sls deploy`)
#         - Effect: Allow
#           Action:
#           - lambda:GetAlias
#           - lambda:GetFunction
#           - lambda:GetFunctionConfiguration
#           - lambda:GetPolicy
#           - lambda:ListAliases
#           - lambda:ListVersionsByFunction
#           - lambda:AddPermission
#           - lambda:CreateAlias
#           - lambda:InvokeFunction
#           - lambda:PublishVersion
#           - lambda:RemovePermission
#           # Note: `UpdateEventSourceMapping` looks like wrong ARN
#           # https://iam.cloudonaut.io/reference/lambda/UpdateEventSourceMapping.html
#           - lambda:Update*
#           Resource:
#           # `sls-${ServiceName}-${Stage}-${Handler/Function Name}`
#           - !Sub "arn:${AWS::Partition}:lambda:${AwsRegion}:${AWS::AccountId}:function:sls-${ServiceName}-${Stage}-*"


#         # API Gateway (`sls deploy`)
#         - Effect: Allow
#           Action:
#           - apigateway:GET
#           - apigateway:POST
#           - apigateway:PUT
#           - apigateway:DELETE
#           Resource:
#           # **NOTE**: This is difficult to lock down because we need the actual
#           # `$api-id` for a `!Ref` which we don't know ahead of time. It's
#           # created dynamically as a part of `sls` provisioning.
#           #
#           # See:
#           # - https://iam.cloudonaut.io/reference/apigateway.html
#           # - https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
#           #
#           # No partition
#           - !Sub "arn:aws:apigateway:${AwsRegion}:${AWS::AccountId}:/restapis*"


#         # Logs (`sls logs`)
#         - Effect: Allow
#           Action:
#           - logs:DescribeLogStreams
#           - logs:DescribeLogGroups
#           - logs:FilterLogEvents
#           - logs:GetLogEvents
#           Resource:
#           # `sls-${ServiceName}-${Stage}-${Handler/Function Name}`
#           # https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html#arn-syntax-cloudwatch-logs
#           # Note: Need trailing `*` in `log-stream:*` to allow viewing specific logs in AWS console.
#           - !Sub "arn:${AWS::Partition}:logs:${AwsRegion}:${AWS::AccountId}:log-group:/aws/lambda/sls-${ServiceName}-${Stage}-*:log-stream:*"


#         # KMS: Use keys
#         - Effect: Allow
#           Action:
#           - kms:Encrypt
#           - kms:GenerateDataKey
#           - kms:Decrypt
#           Resource:
#           - !GetAtt KmsKey.Arn


#         # SecretsManager: Read / write secrets
#         - Effect: Allow
#           Action:
#           - secretsmanager:PutSecretValue
#           - secretsmanager:GetSecretValue
#           Resource:
#           - !Sub "arn:aws:secretsmanager:${AwsRegion}:${AWS::AccountId}:secret:${ServiceName}/${Stage}/*"


#         # serverless-plugin-warmup: Different named resource.
#         - Effect: Allow
#           Action:
#           - events:DescribeRule
#           - events:PutRule
#           Resource:
#           # Deal with truncation for warmup plugin:
#           # E.g. `rule/sls-${SERVICE}-develo-WarmUpPluginEventsRuleSc-V86D3GXQSYCP`
#           - !Sub "arn:aws:events:${AwsRegion}:${AWS::AccountId}:rule/sls-${ServiceName}-*-WarmUpPlugin*-*"

