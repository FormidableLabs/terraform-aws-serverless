# TODO: Decide if part of ths module or separate module?
# Deps
# - iam
#         # TODO(IamPolicyAdmin): Xray: view traces
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

