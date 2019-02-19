AWS Serverless Infrastructure
=============================
[![Terraform][tf_img]][tf_site]
[![Travis Status][trav_img]][trav_site]

Get your [serverless][] framework application to AWS, the **right way**.

## Overview

Getting a [serverless][] application all the way to production in AWS **correctly** using **securely** can be quite challenging. In particular, things like:

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
    * **Developer, CI**: AWS users assigned to the `developer|ci` groups can update a `serverless` application and do non-mutating things like view logs, perform rollbacks, etc.

In this manner, once an AWS superuser deploys a Terraform stack with this module and assigns IAM groups, the rest of the development / devops teams and CI can build and deploy Serverless applications to appropriate cloud targets with the minimum necessary privileges and isolation across services + environments + IAM roles.

## TODO_REST_OF_DOCS

[serverless]: https://serverless.com/
[Terraform]: https://www.terraform.io

[tf_img]: https://img.shields.io/badge/terraform-published-blue.svg
[tf_site]: https://registry.terraform.io/modules/FormidableLabs/serverless/aws
[trav_img]: https://api.travis-ci.org/FormidableLabs/inspectpack.svg
[trav_site]: https://travis-ci.org/FormidableLabs/inspectpack
