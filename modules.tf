###############################################################################
# Autoload: modules
#
# This file dynamically declares autoloaded modules specified via the
# `modules` parameter in the root module of this project.
###############################################################################

locals = {
  # We only have to match as `modules` is already distinct.
  _modules_xray = "${matchkeys(local.modules, local.modules, list("xray"))}"
  _modules_vpc  = "${matchkeys(local.modules, local.modules, list("vpc"))}"
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
