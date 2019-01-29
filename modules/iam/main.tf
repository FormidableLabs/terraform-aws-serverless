locals {
  tf_service_name = "${var.tf_service_name != "" ? var.tf_service_name : "tf-${var.service_name}"}"
  sls_service_name = "${var.sls_service_name != "" ? var.sls_service_name : "sls-${var.service_name}"}"
}
