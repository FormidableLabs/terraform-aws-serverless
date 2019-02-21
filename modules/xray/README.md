


AWS Serverless - X-ray Module
=============================

This module enables [AWS X-ray][] support for [serverless][] framework applications.

## Overview

This module adds [IAM permissions][xray_iam] to the Lambda execution role created by the Serverless framework as part of its CloudFormation stack so that the role may send trace data to AWS.

## Integration

### Reference project

Perhaps the easiest place to start is our [sample reference project][ref_project] that creates a Serverless framework service named `simple-reference` that integrates the core module and submodules of this project. The relevant files to review include:

- Serverless framework
    - [serverless.yml](https://github.com/FormidableLabs/aws-lambda-serverless-reference/blob/master/serverless.yml): Serverless framework configuration. The `xray` function is configured with X-ray tracing.
- Example Node.js handlers/servers
    - [src/server/xray.js](https://github.com/FormidableLabs/aws-lambda-serverless-reference/blob/master/src/server/xray.js): Example server additionally enabling [AWS X-Ray][] performance tracing additionally using the `serverless_xray` submodule.

### Module integration

The first step is to make sure that the [core IAM `serverless` module][core_module] is integrated. Then, this optional module can be added as a resource after.

_Note_: There is no direct dependencies between the core module and this submodule because everything is re-using well-known resource names that are defined across the Serverless framework stack and your Terraform support stack.

```hcl
# variables.tf
variable "stage" {
  description = "The stage/environment to deploy to. Suggest: `sandbox`, `development`, `staging`, `production`."
  default     = "development"
}

# main.tf
provider "aws" {
  region  = "us-east-1"
  version = "~> 1.19"
}

# Core `serverless` IAM support.
module "serverless" {
  source = "FormidableLabs/serverless/aws"

  region       = "us-east-1"
  service_name = "sparklepants"
  stage        = "${var.stage}"
}

# Add optional X-ray support to lambda execution roles.
module "serverless_xray" {
  source = "FormidableLabs/serverless/aws//modules/xray"

  # Same variables as for `serverless` module.
  region       = "us-east-1"
  service_name = "sparklepants"
  stage        = "${var.stage}"

  # (Default values)
  # iam_region        = `*`
  # iam_partition     = `*`
  # iam_account_id    = `AWS_CALLER account`
  # tf_service_name   = `tf-SERVICE_NAME`
  # sls_service_name  = `sls-SERVICE_NAME`
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

functions:
  server:
    # ...

resources:
  Resources:
    # Enable X-ray tracing on the Lambda. The `serverless_xray` module gives
    # correct IAM permissions to enable this resource on the Serverless-
    # generated CloudFormation Stack.
    ServerLambdaFunction: # Generated resource name for `server` function...
      Properties:
        TracingConfig:
          Mode: Active
```

The parameters (located in [variables.tf](variables.tf)) are exactly the same as for the [core IAM module][core_module].

[serverless]: https://serverless.com/
[Terraform]: https://www.terraform.io
[AWS X-Ray]: https://aws.amazon.com/xray/

[core_module]: ../../README.md
[xray_iam]: https://docs.aws.amazon.com/IAM/latest/UserGuide/list_awsx-ray.html
