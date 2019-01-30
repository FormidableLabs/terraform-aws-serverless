# TODO: Decide if part of ths module or separate module?
# Deps
# - iam
#         # TODO(IamPolicyDeveloper): KMS: Use keys
#         - Effect: Allow
#           Action:
#           - kms:Encrypt
#           - kms:GenerateDataKey
#           - kms:Decrypt
#           Resource:
#           - !GetAtt KmsKey.Arn
#         # TODO(IamPolicyAdmin): KMS: Manage keys
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

