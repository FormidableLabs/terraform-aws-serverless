AWS Serverless - VPC Module
===========================

This module enables [AWS VPC][] support for [serverless][] framework applications.

## Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Overview](#overview)
- [Integration](#integration)
  - [Reference project](#reference-project)
  - [Module integration](#module-integration)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Overview

This module adds [IAM permissions][vpc_iam] to the Lambda execution role created by the Serverless framework  and the `developer` IAM role created by the core module of this project to enable deploying a Serverless framework application into an existing VPC.

_Note_: This module does _not_ actually create a VPC for you, just the permissions to use one. If you need a VPC, see our [reference project](#reference-project) for guidance.

## Integration

### Reference project

Perhaps the easiest place to start is our [sample reference project][ref_project] that creates a Serverless framework service named `simple-reference` that integrates the core module and submodules of this project. The relevant files to review include:

- Serverless framework
    - [serverless.yml](https://github.com/FormidableLabs/aws-lambda-serverless-reference/blob/master/serverless.yml): Serverless framework configuration. The `vpc` function is a simple Express application (same as [`base`](https://github.com/FormidableLabs/aws-lambda-serverless-reference/blob/master/src/server/base.js)) deployed to a VPC.

Note that the reference project provides two very useful examples:

- **Per-function `vpc` in `serverless.yml`**: We only add the VPC configuration to the `functions.vpc` function (not the global `provider`).
- **An actual VPC instance**: We use the wonderful [`terraform-aws-modules/vpc/aws`](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.64.0) to create a [2xAZ private + public subnetted VPC](https://github.com/FormidableLabs/aws-lambda-serverless-reference/blob/master/terraform/main.tf#L51-L165) with internet access, a dedicated security group that only allows egress traffic, and export the security group ID + subnet IDs via a small CloudFormation stack for easy consumption in [`serverless.yml`](https://github.com/FormidableLabs/aws-lambda-serverless-reference/blob/master/serverless.yml#L62-L77)

### Module integration

The first step is to make sure that the [core IAM `serverless` module][core_module] is integrated. Then, this optional module can be added as a resource after.

_Note_: There are no direct dependencies between the core module and this submodule because everything is re-using well-known resource names that are defined across the Serverless framework stack and your Terraform support stack.

```hcl
# variables.tf
variable "stage" {
  description = "The stage/environment to deploy to. Suggest: `sandbox`, `development`, `staging`, `production`."
  default     = "development"
}

# main.tf
provider "aws" {
  region  = "us-east-1"
}

# Core `serverless` IAM support.
module "serverless" {
  source = "FormidableLabs/serverless/aws"

  region       = "us-east-1"
  service_name = "sparklepants"
  stage        = "${var.stage}"
}

# Add optional VPC support to lambda execution and IAM group roles.
module "serverless_vpc" {
  source = "FormidableLabs/serverless/aws//modules/vpc"

  # Same variables as for `serverless` module.
  region       = "us-east-1"
  service_name = "sparklepants"
  stage        = "${var.stage}"

  # (Default values)
  # iam_region          = `*`
  # iam_partition       = `*`
  # iam_account_id      = `AWS_CALLER account`
  # tf_service_name     = `tf-SERVICE_NAME`
  # sls_service_name    = `sls-SERVICE_NAME`
  # role_admin_name     = `admin`
  # role_developer_name = `developer`
  # role_ci_name        = `ci`
}
```

That pairs with a `serverless.yml` configuration:

```yml
# This value needs to either be `sls-` + `service_name` module input *or*
# be specified directly as the module input `sls_service_name`.
service: sls-sparklepants

provider:
  name: aws
  runtime: nodejs8.10
  region: "us-east-1"
  stage: ${opt:stage, "development"}
  vpc:
    securityGroupIds:
      - INSERT_SG_ID(S)
    subnetIds:
      - INSERT_SUBNET_ID(S)

functions:
  server:
    # ...
```

The parameters (located in [variables.tf](variables.tf)) are exactly the same as for the [core IAM module][core_module].


[serverless]: https://serverless.com/
[Terraform]: https://www.terraform.io
[AWS VPC]: https://aws.amazon.com/vpc/
[vpc_iam]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_IAM.html

[core_module]: ../../README.md
[ref_project]: https://github.com/FormidableLabs/aws-lambda-serverless-reference
