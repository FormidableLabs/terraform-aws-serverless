AWS Serverless - Canary Module
=============================

This module enables canary deploy support for [serverless][] framework applications using [serverless-plugin-canary-deployments][].

## Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Overview](#overview)
- [Integration](#integration)
  - [Reference project](#reference-project)
  - [Module integration](#module-integration)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Overview

This module adds [IAM permissions][canary_iam] to the Lambda execution role created by the Serverless framework as part of its CloudFormation stack so that the role may create, rollback, and destroy
canary deploys with CodeDeploy Lambda traffic shifting.

## Integration

### Reference project

Perhaps the easiest place to start is our [sample reference project][ref_project] that creates a Serverless framework service named `simple-reference` that integrates the core module and submodules of this project. The relevant files to review include:

- Serverless framework
    - [serverless.yml](https://github.com/FormidableLabs/aws-lambda-serverless-reference/blob/master/serverless.yml): Serverless framework configuration. The `canary` function is configured to start a canary deploy on `sls deploy`: 10% new Lambda for five minutes, then 100% new Lambda after.

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

# Add serverless-plugin-canary-deployments to lambda execution roles.
module "serverless_canary" {
  source = "FormidableLabs/serverless/aws//modules/canary"

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
  # role_ci_name        =  ""
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

plugins:
  # ...
  - serverless-plugin-canary-deployments

functions:
  server:
    # ...
    deploymentSettings:
      type: Canary10Percent5Minutes
      alias: Live
```

The parameters (located in [variables.tf](variables.tf)) are exactly the same as for the [core IAM module][core_module].

[serverless]: https://serverless.com/
[serverless-plugin-canary-deployments]: https://github.com/davidgf/serverless-plugin-canary-deployments
[Terraform]: https://www.terraform.io

[core_module]: ../../README.md
[canary_iam]: https://docs.aws.amazon.com/IAM/latest/UserGuide/list_awscodedeploy.html
[ref_project]: https://github.com/FormidableLabs/aws-lambda-serverless-reference
