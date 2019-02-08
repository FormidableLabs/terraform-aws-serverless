AWS Serverless Infrastructure
=============================
[![Terraform](https://img.shields.io/badge/terraform-published-blue.svg)](https://registry.terraform.io/modules/FormidableLabs/serverless/aws)

Get your [serverless][] framework application to AWS, the **right way**.

## Overview

Getting a [serverless][] application all the way to production in AWS **correctly** using **securely** can be quite challenging. In particular, things like:

- Locking down IAM permissions to the minimum needed for different conceptual "roles" (e.g., `admin`, `developer`, `ci`).
- Providing a scheme for different environments/stages (e.g., `development`, `staging`, `production`).

... lack reasonable guidance to practically achieve in real world applications.

This module provides a production-ready base of AWS permissions / resources to support a `serverless` framework application and help manage development / deployment workflows and maintenance. Specifically, it provides:

- **IAM Groups**: Role-specific groups to attach to AWS users to give humans and CI the minimum level of permissions locked to both a specific `serverless` service and stage/environment.
- **Custom Lambda Execution Role**: You will often need to extend the serverless-provided Lambda execution role. This module provides an analagous one that you can customize even further, completely in Terraform.

## Concepts

This module allows practical isolation / compartmentalization of privileges within a single AWS account along the folowing axes:

* **Stage/Environment**: An arbitrary environment to isolate -- this module doesn't restrict selection in any way other than there has to be at least one. In practice, a good set of choices may be something like `sandbox`, `development`, `staging`, `production`.
* **IAM Groups**: This module creates/enforces a scheme wherein:
    * **Admin**: AWS users assigned to the `admin` group can create/update/delete a `serverless` application and do pretty much anything that the `serverless` framework permits out of the box.
    * **Developer, CI**: AWS users assigned to the `developer|ci` groups can update a `serverless` application and do non-mutating things like view logs, perform rollbacks, etc.

## TODO_REST_OF_DOCS
