Changes
=======

## UNRELEASED

* Adds `opt_many_lambdas` option to allow Lambda function create/delete privileges for the `developer|ci` groups to facilitate application development around many independent functions.
  [#29](https://github.com/FormidableLabs/terraform-aws-serverless/issues/29)
* Lock down `lambda:CreateFunction` to `sls_lambda_arn`.
* Expand `logs:DescribeLogGroups` to wildcard-like `sls_log_stream_all_arn`. Needed for create-then-delete-then-create... scenario for functions.

## 0.1.1

* Adds `role_*_name` option to name IAM groups, policies, etc. besides default `admin|developer|ci`.

## 0.1.0

* Module: Core IAM support for `serverless` framework.
* Submodule: AWS X-ray support for `serverless` apps.
