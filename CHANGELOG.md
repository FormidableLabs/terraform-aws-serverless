Changes
=======

## 0.4.0

* Adds a `lambda_role_name` option to allow use of a custom Lambda execution role in lieu of the default Serverless-generated role.

## 0.3.0

* Submodule: Add `vpc` submodule support for `serverless` apps.
  [#10](https://github.com/FormidableLabs/terraform-aws-serverless/issues/10)
* Internal: Add `tf_group_ROLE_name` helper `locals`.

## 0.2.3

* BUG: Add more IAM permissions after `serverless` framework introduced default S3 bucket encryption in [serverless/serverless#5800](https://github.com/serverless/serverless/pull/5800). _Note_ if you have an existing serverless deployment, after updating the Terraform support stack you will need to run an `admin` user serverless deploy to properly set the encryption configuration for subsequent `developer|ci` deploys.
  [#33](https://github.com/FormidableLabs/terraform-aws-serverless/issues/33)

## 0.2.2

* Add IAM group name outputs for `admind|developer|ci`.
  [#34](https://github.com/FormidableLabs/terraform-aws-serverless/issues/34)

## 0.2.1

* Move `cloudformation:List|Get` permissions to `developer|ci` policy since they're limited already to `sls_cloudformation_arn`.
  [#26](https://github.com/FormidableLabs/terraform-aws-serverless/issues/26)

## 0.2.0

* Adds `opt_many_lambdas` option to allow Lambda function create/delete privileges for the `developer|ci` groups to facilitate application development around many independent functions.
  [#29](https://github.com/FormidableLabs/terraform-aws-serverless/issues/29)
* Lock down `lambda:CreateFunction` to `sls_lambda_arn`.
* Expand `logs:DescribeLogGroups` to wildcard-like `sls_log_stream_all_arn`. Needed for create-then-delete-then-create... scenario for functions.

## 0.1.1

* Adds `role_*_name` option to name IAM groups, policies, etc. besides default `admin|developer|ci`.

## 0.1.0

* Module: Core IAM support for `serverless` framework.
* Submodule: AWS X-ray support for `serverless` apps.
