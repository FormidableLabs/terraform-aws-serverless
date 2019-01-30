# TODO: Decide if part of ths module or separate module?
# Deps
# - iam
# - kms
#         # TODO(IamPolicyDeveloper): SecretsManager: Read / write secrets
#         - Effect: Allow
#           Action:
#           - secretsmanager:PutSecretValue
#           - secretsmanager:GetSecretValue
#           Resource:
#           - !Sub "arn:aws:secretsmanager:${AwsRegion}:${AWS::AccountId}:secret:${ServiceName}/${Stage}/*"
#         # TODO(IamPolicyAdmin): SecretsManager: Manage secrets
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

