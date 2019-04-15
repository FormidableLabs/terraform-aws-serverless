AWS Serverless Module
=====================
[![Terraform][tf_img]][tf_site]
[![Travis Status][trav_img]][trav_site]
[![Maintenance Status][maintenance-image]](#maintenance-status)

Get your [serverless][] framework application to AWS, the **right way**.

## Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Overview](#overview)
- [Concepts](#concepts)
- [Modules](#modules)
- [IAM Notes](#iam-notes)
- [Integration](#integration)
  - [Reference project](#reference-project)
  - [Module integration](#module-integration)
  - [AWS IAM group integration](#aws-iam-group-integration)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Overview

Getting a [serverless][] application all the way to production in AWS **correctly** and **securely** can be quite challenging. In particular, things like:

- Locking down IAM permissions to the minimum needed for different conceptual "roles" (e.g., `admin`, `developer`, `ci`).
- Providing a scheme for different environments/stages (e.g., `development`, `staging`, `production`).

... lack reasonable guidance to practically achieve in real world applications.

This [Terraform][] module provides a production-ready base of AWS permissions / resources to support a `serverless` framework application and help manage development / deployment workflows and maintenance. Specifically, it provides:

- **IAM Groups**: Role-specific groups to attach to AWS users to give humans and CI the minimum level of permissions locked to both a specific `serverless` service and stage/environment.

## Concepts

This module allows practical isolation / compartmentalization of privileges within a single AWS account along the folowing axes:

* **Stage/Environment**: An arbitrary environment to isolate -- this module doesn't restrict selection in any way other than there has to be at least one. In practice, a good set of choices may be something like `sandbox`, `development`, `staging`, `production`.
* **IAM Groups**: This module creates/enforces a scheme wherein:
    * **Admin**: AWS users assigned to the `admin` group can create/update/delete a `serverless` application and do pretty much anything that the `serverless` framework permits out of the box.
    * **Developer, CI**: AWS users assigned to the `developer|ci` groups can update a `serverless` application and do other things like view logs, perform rollbacks, etc.

In this manner, once an AWS superuser deploys a Terraform stack with this module and assigns IAM groups, the rest of the development / devops teams and CI can build and deploy Serverless applications to appropriate cloud targets with the minimum necessary privileges and isolation across services + environments + IAM roles.

## Modules

This project provides a core base module that is the minimum that must be used. Once the core is in place, then other optional submodules can be added.

- **Core (`/*`)**: Provides supporting IAM policies, roles, and groups so that an engineering team / CI can effectively create and maintain `serverless` Framework applications locked down to specific applications + environments with the minimum permissions needed.
- **X-Ray (`modules/xray`)**: Optional submodule to add needed IAM support to enable AWS X-Ray performance tracing in a Serverless framework application. See the [submodule documentation](./modules/xray/README.md).

## IAM Notes

The IAM permissions are locked down to service + environment + role-specific ARNs as much as is possible within the AWS IAM and Serverless framework constraints. All of our modules/submodules use the same set of base ARNs declared, e.g., in [variables.tf](./variables.tf) and can be considered as follows:

**Fully locked down**: These ARNs are sufficiently locked to service + environment.

* `sls_cloudformation_arn`: Serverless-generated CloudFormation stack.
* `sls_deploy_bucket_arn`: Serverless deployment bucket that stores Lambda code. (Note that our ARN accounts for service name truncation).
* `sls_log_stream_arn`: Serverless target log stream.
* `sls_events_arn`: Serverless created CloudWatch events.
* `sls_lambda_arn`: Serverless lambda functions.
* `sls_lambda_role_arn`: Serverless lambda execution role.

**Not locked down**: These ARNs could be tighter, but presently are not.

* `sls_apigw_arn`: Serverless API Gateway. The issue is that the ID of the resource is dynamically created during Serverless initial provisioning, so this module can't know it ahead of time. We have [a filed issue](https://github.com/FormidableLabs/terraform-aws-serverless/issues/8) to track and research potential tightening solutions.

**IAM Wildcards**: Unfortunately, AWS IAM only allows wildcards (`"*"`) on certain resources, so we cannot actually lock down more. Accordingly, we limit the permissions to _only_ what is needed with a bias towards sticking such permissions in the `admin` IAM group. Here are our current wildcards:

_Core IAM module_

* `admin`
    - `cloudformation:ListStacks`
    - `cloudformation:PreviewStackUpdate`
    - `lambda:GetEventSourceMapping`
    - `lambda:ListEventSourceMappings`
    - `lambda:ListFunctions`
    - `cloudwatch:GetMetricStatistics`
* `developer|ci`:
    - `cloudformation:ValidateTemplate`
* One of the above (depending on `opt_many_lambdas`):
    - `logs:DescribeLogGroups`

_X-ray submodule_

* Lambda execution role:
    - `xray:PutTraceSegments`
    - `xray:PutTelemetryRecords`

## Integration

### Reference project

Perhaps the easiest place to start is our [sample reference project][ref_project] that creates a Serverless framework service named `simple-reference` that integrates the core module and submodules of this project. The relevant files to review include:

- Terraform infrastructure
    - [aws/bootstrap.yml](https://github.com/FormidableLabs/aws-lambda-serverless-reference/blob/master/aws/bootstrap.yml): Terraform remote state storage / bootstrap.
    - [terraform/variables.tf](https://github.com/FormidableLabs/aws-lambda-serverless-reference/blob/master/terraform/variables.tf): Terraform variables.
    - [terraform/main.tf](https://github.com/FormidableLabs/aws-lambda-serverless-reference/blob/master/terraform/main.tf): Terraform resources / integration.
- Serverless framework
    - [serverless.yml](https://github.com/FormidableLabs/aws-lambda-serverless-reference/blob/master/serverless.yml): Serverless framework configuration.
- Example Node.js handlers/servers
    - [src/server/base.js](https://github.com/FormidableLabs/aws-lambda-serverless-reference/blob/master/src/server/base.js): Example "hello world" server using only the core `serverless` module.

### Module integration

Here's a basic integration of the core `serverless` module:

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

  # (Default values)
  # iam_region          = `*`
  # iam_partition       = `*`
  # iam_account_id      = `AWS_CALLER account`
  # tf_service_name     = `tf-SERVICE_NAME`
  # sls_service_name    = `sls-SERVICE_NAME`
  # role_admin_name     = `admin`
  # role_developer_name = `developer`
  # role_ci_name        = `ci`
  # opt_many_lambdas    = false
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
```

Let's unpack the parameters a bit more (located in [variables.tf](variables.tf)):

- `service_name`: A service name is something that defines the unique application that will match up with the serverless application. E.g., something boring like `simple-reference` or `graphql-server` or exciting like `unicorn` or `sparklepants`.
- `stage`: The current stage that will match up with the `serverless` framework deployment. These are arbitrary, but can be something like `development`/`staging`/`production`.
- `region`: The deployed region of the service. Defaults to the current caller's AWS region. E.g., `us-east-1`.
- `iam_region`: The [AWS region][] to limit IAM privileges to. Defaults to `*`. The difference with `region` is that `region` has to be one specific region like `us-east-1` to match up with Serverless framework resources, whereas `iam_region` can be a single region or `*` wildcard as it's just an IAM restriction.
- `iam_partition`: The [AWS partition][] to limit IAM privileges to. Defaults to `*`.
- `iam_account_id`: The [AWS account ID][] to limit IAM privileges to. Defaults to the current caller's account ID.
- `tf_service_name`: The service name for Terraform-created resources. It is very useful to distinguish between those created by Terraform / this module and those created by the Serverless framework. By default, `tf-${service_name}` for "Terraform". E.g., `tf-simple-reference` or `tf-sparklepants`.
- `sls_service_name`: The service name for Serverless as defined in `serverless.yml` in the `service` field. Highly recommended to match our default of `sls-${service_name}` for "Serverless".
- `role_admin_name`: The name for the IAM group, policy, etc. for administrators. (Default: `admin`).
- `role_developer_name`: The name for the IAM group, policy, etc. for developers. (Default: `developer`).
- `role_ci_name`: The name for the IAM group, policy, etc. for Continuous Integration (CI) / automation. (Default: `ci`).
- `opt_many_lambdas`: By default, only the `admin` group can create and delete Lambda functions which gives extra security for a "mono-Lambda" application approach. However, many Lambda applications utilize multiple different functions which need to be created and deleted by the `developer` and `ci` group. Setting this option to `true` enables Lambda function create/delete privileges for all groups. (Default: `false`)

Most likely, an AWS superuser will be needed to run the Terraform application for these IAM / other resources.

### AWS IAM group integration

Once the core module is applied, three IAM groups will be created in the form of `${tf_service_name}-${stage}-(admin|developer|ci)`. This typically looks something like:

- `tf-${service_name}-${stage}-admin`: Can create/delete/update the Severless app.
- `tf-${service_name}-${stage}-developer`: Can deploy the Severless app.
- `tf-${service_name}-${stage}-ci`: Can deploy the Severless app.

Once these groups exist, an AWS superuser can then attach these groups to AWS individual users as appropriate for the combination of service + stage + role (admin, developer, CI). Or, the IAM group attachments could be controlled via Terraform as well!

The main upshot of this is after attachment, a given AWS user has the minimum necessary privileges for exactly the level of Serverless framework commands they need. Our example Serverless application [reference project][ref_project] documentation has many examples of various `serverless` commands and which IAM group can properly run them.

[serverless]: https://serverless.com/
[Terraform]: https://www.terraform.io
[AWS region]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html#cfn-pseudo-param-region
[AWS partition]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html#cfn-pseudo-param-partition
[AWS account ID]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html#cfn-pseudo-param-accountid
[AWS X-Ray]: https://aws.amazon.com/xray/

## Maintenance Status

**Active:** Formidable is actively working on this project, and we expect to continue for work for the foreseeable future. Bug reports, feature requests and pull requests are welcome. 

[maintenance-image]: https://img.shields.io/badge/maintenance-active-green.svg
[tf_img]: https://img.shields.io/badge/terraform-published-blue.svg
[tf_site]: https://registry.terraform.io/modules/FormidableLabs/serverless/aws
[trav_img]: https://api.travis-ci.org/FormidableLabs/inspectpack.svg
[trav_site]: https://travis-ci.org/FormidableLabs/inspectpack
[ref_project]: https://github.com/FormidableLabs/aws-lambda-serverless-reference
