###############################################################################
# Module Variables
#
# _Note_: These variables are defined in the root module `variables.tf` and
# copied to all other submodules in a build step. The root module contains the
# real source of truth.
###############################################################################

# AWS
variable "iam_partition" {
  description = "The IAM partition restriction for permissions (defaults to 'any partition')."
  default     = "*"
}

variable "iam_account_id" {
  description = "The AWS account ID to limit to in IAM. Defaults to: current inferred account id. Could be wildcarded."
  default     = ""
}

variable "region" {
  description = "The deploy target region in AWS. Defaults to: current inferred region"
  default     = ""
}

variable "iam_region" {
  description = "The IAM region restriction for permissions (defaults to 'any region')."
  default     = "*"
}

# Our custom stack / environment
variable "stage" {
  description = "The stage/environment to deploy to. Suggest: `sandbox`, `development`, `staging`, `production`."
  default     = "development"
}

variable "iam_stage" {
  description = "The IAM stage restriction for permissions. Wildcarding stage is useful for dynamic environment creation."
  default     = ""
}

variable "service_name" {
  description = "Name of service / application"
}

# Terraform service name.
# _Note_: Defaults are performed in local variables.
variable "tf_service_name" {
  description = "The unique name of service for Terraform resources. Defaults to: `tf-SERVICE_NAME`."
  default     = ""
}

# Serverless version (to synchronize with).
# _Note_: Defaults are performed in local variables.
variable "sls_service_name" {
  description = "The service name from Serverless configuration. Defaults to: `sls-SERVICE_NAME`."
  default     = ""
}

variable "lambda_role_name" {
  description = "Custom Lambda role to override the default Serverless one. The custom role should provide at least the same level of access as the default."
  default     = ""
}

# Configurable names for roles. Default `admin|developer|ci`.
variable "role_admin_name" {
  description = "Administrator role name"
  default     = "admin"
}

variable "role_developer_name" {
  description = "Developer role name"
  default     = "developer"
}

variable "role_ci_name" {
  description = "Continuous Integration (CI) role name"
  default     = "ci"
}

variable "opt_many_lambdas" {
  description = "Allow all groups (incl developer, ci) to create and delete Lambdas"
  default     = false
}

# Autoload: modules
variable "modules" {
  description = "Submodules to autoload (e.g. `xray`, `vpc`)"
  type        = "list"
  default     = []
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# AWS / Serverless framework configuration.
locals {
  iam_partition       = "${var.iam_partition}"
  iam_account_id      = "${var.iam_account_id != "" ? var.iam_account_id : data.aws_caller_identity.current.account_id}"
  region              = "${var.region != "" ? var.region : data.aws_region.current.name}"
  iam_region          = "${var.iam_region}"
  stage               = "${var.stage}"
  iam_stage           = "${var.iam_stage != "" ? var.iam_stage : var.stage}"
  service_name        = "${var.service_name}"
  tf_service_name     = "${var.tf_service_name != "" ? var.tf_service_name : "tf-${var.service_name}"}"
  sls_service_name    = "${var.sls_service_name != "" ? var.sls_service_name : "sls-${var.service_name}"}"
  lambda_role_name    = "${var.lambda_role_name}"
  role_admin_name     = "${var.role_admin_name}"
  role_developer_name = "${var.role_developer_name}"
  role_ci_name        = "${var.role_ci_name}"
  opt_many_lambdas    = "${var.opt_many_lambdas}"
  modules             = "${distinct(var.modules)}"

  tags = "${map(
    "Service", "${var.service_name}",
    "Stage", "${var.stage}",
  )}"
}

# Capture repeated/complicated AWS IAM resources to a single location.
locals {
  # Our Terraform created names.
  tf_group_admin_name     = "${local.tf_service_name}-${local.stage}-${local.role_admin_name}"
  tf_group_developer_name = "${local.tf_service_name}-${local.stage}-${local.role_developer_name}"
  tf_group_ci_name        = "${local.tf_service_name}-${local.stage}-${local.role_ci_name}"

  # Serverless CloudFormation stack ARN.
  sls_cloudformation_arn = "arn:${local.iam_partition}:cloudformation:${local.iam_region}:${local.iam_account_id}:stack/${local.sls_service_name}-${local.iam_stage}/*"

  # Serverless target deployment bucket ARN.
  # - A long service name can endup with truncated bucket names like:
  #   `sls-SERVICE-de-serverlessdeploymentbuck-47ati3in2360`
  #   and possibly even more truncated, so we take a conservative approach.
  # - No region or account id allowed. https://iam.cloudonaut.io/reference/s3.html
  sls_deploy_bucket_arn = "arn:${local.iam_partition}:s3:::${local.sls_service_name}-*-serverless*-*"

  # Serverless created log stream.
  sls_log_stream_arn = "arn:${local.iam_partition}:logs:${local.iam_region}:${local.iam_account_id}:log-group:/aws/lambda/${local.sls_service_name}-${local.iam_stage}-*:log-stream:"

  # Serverless created CloudWatch events.
  sls_events_arn = "arn:${local.iam_partition}:events:${local.iam_region}:${local.iam_account_id}:rule/${local.sls_service_name}-${local.iam_stage}"

  # Serverless lambda function ARN.
  sls_lambda_arn = "arn:${local.iam_partition}:lambda:${local.iam_region}:${local.iam_account_id}:function:${local.sls_service_name}-${local.iam_stage}-*"

  # The built-in serverless Lambda execution role.
  #
  # _Note_: We need **actual name** to match real role, which means
  # `local.region` and not `local.iam_region`.
  sls_lambda_role_default_name = "${local.sls_service_name}-${local.stage}-${local.region}-lambdaRole"

  # The name, custom or default, of the Lambda execution role to attach policies to.
  sls_lambda_role_name = "${local.lambda_role_name != "" ? local.lambda_role_name : local.sls_lambda_role_default_name}"

  # The built-in serverless Lambda execution role ARN.
  #
  # Note that we use `iam_region` to potentially wildcard the IAM permission
  # in the actual name of the role.
  #
  # - No region allowed in ARN. See https://iam.cloudonaut.io/reference/iam.html
  sls_lambda_role_default_arn = "arn:${local.iam_partition}:iam::${local.iam_account_id}:role/${local.sls_service_name}-${local.iam_stage}-${local.iam_region}-lambdaRole"

  sls_lambda_role_custom_arn = "arn:${local.iam_partition}:iam::${local.iam_account_id}:role/${local.lambda_role_name}"
  sls_lambda_role_arn        = "${local.lambda_role_name != "" ? local.sls_lambda_role_custom_arn : local.sls_lambda_role_default_arn}"

  # The serverless created APIGW.
  #
  # **NOTE**: This is difficult to lock down because we need the actual
  # `$api-id` for a `!Ref` which we don't know ahead of time. It's
  # created dynamically as a part of `sls` provisioning.
  #
  # TODO(8): Research locking down more.
  # https://github.com/FormidableLabs/serverless-iam-terraform/issues/8
  #
  # See:
  # - https://iam.cloudonaut.io/reference/apigateway.html
  # - https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  #
  # E.g. arn:aws:apigateway:us-east-1::/restapis/ibln8d639e/deployments
  # - **Note**: Adding `${local.iam_account_id}` will cause at least `-developer`
  #   to fail for permissions.
  sls_apigw_arn = "arn:${local.iam_partition}:apigateway:${local.iam_region}::/restapis*"

  # All log streams.
  # Needed for `logs:DescribeLogGroups`
  sls_log_stream_all_arn = "arn:${local.iam_partition}:logs:${local.iam_region}:${local.iam_account_id}:log-group::log-stream:"
}
