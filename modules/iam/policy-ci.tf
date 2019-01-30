###############################################################################
# Policy: CI
# ----------
# A CI user has all the privileges of a developer and presently has no
# additional permissions. So we provide a completely empty policy here that
# is attached and exported for extensibility by module consumers.
###############################################################################
resource "aws_iam_policy" "ci" {
  name   = "${local.tf_service_name}-${local.stage}-ci"
  path   = "/"
  policy = "${data.aws_iam_policy_document.ci.json}"
}

data "aws_iam_policy_document" "ci" {}
