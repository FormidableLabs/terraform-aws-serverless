###############################################################################
# Autoload: modules
#
# This file dynamically declares autoloaded modules specified via the
# `modules` parameter in the root module of this project.
#
# ## Notes
# - Ideally we'd like to only dynamically add modules with something like
#   `count  = "${length(local._modules_xray)}"`. Unfortunately, `count` is not
#   supported for modules: https://github.com/hashicorp/terraform/issues/953
# - We also tried doing interpolation on `source` to switch between a "real"
#   modules and an "empty" one. Also not supported:
#   https://github.com/hashicorp/terraform/issues/1439
###############################################################################

locals = {
  # We only have to match as `modules` is already distinct.
  _modules_xray = "${matchkeys(local.modules, local.modules, list("xray"))}"
  _modules_vpc  = "${matchkeys(local.modules, local.modules, list("vpc"))}"
}

###############################################################################
# Module(xray): Add X-ray support to lambda execution roles.
###############################################################################
# TODO HERE: `Error: module "serverless_xray": "count" is not a valid argument`
# TODO: OPTION/IDEA: Have a dummy module and interpolate on `source`?
module "serverless_xray" {
  # FAILS count  = "${length(local._modules_xray)}"

  # FAILS source = "${length(local._modules_xray) == 0 ? "./modules/xray" : "./modules/empty"}"

  # Proxy all variables
  region              = "${var.region}"
  service_name        = "${var.service_name}"
  stage               = "${var.stage}"
  modules             = "${var.modules}"
  iam_region          = "${var.iam_region}"
  iam_partition       = "${var.iam_partition}"
  iam_account_id      = "${var.iam_account_id}"
  iam_stage           = "${var.iam_stage}"
  tf_service_name     = "${var.tf_service_name}"
  sls_service_name    = "${var.sls_service_name}"
  role_admin_name     = "${var.role_admin_name}"
  role_developer_name = "${var.role_developer_name}"
  role_ci_name        = "${var.role_ci_name}"
  opt_many_lambdas    = "${var.opt_many_lambdas}"
}

# Autoload: modules
# TODO(autoload): REMOVE TEST
resource "aws_s3_bucket" "todo-remove-modules_xray" {
  count  = "${length(local._modules_xray)}"
  bucket = "TODO-fmd-tf-aws-sls-remove-me-xray-${local._modules_xray[0]}"
  acl    = "private"
}

resource "aws_s3_bucket" "todo-remove-modules_vpc" {
  count  = "${length(local._modules_vpc)}"
  bucket = "TODO-fmd-tf-aws-sls-remove-me-vpc-${local._modules_vpc[0]}"
  acl    = "private"
}
