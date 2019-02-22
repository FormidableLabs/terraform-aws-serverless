Contributing
============

Thanks for contributing!

## Development

We develop this project using `terraform` and `yarn` / Node.js for convenience. Make sure you have both installed.

Because of how Terraform works, we have to format / generate code that goes back into git source. So, make sure to periodically run:

```sh
$ yarn build
```

to update the built files.

### `variables.tf`

The root project `variables.tf` are copied programmatically to all submodules (`modules/*/variables.tf`) and will overwrite any modifications. If you need to change / add to this file, be careful, and do it in the root `variables.tf`.

## Testing

We test out this project using a simple reference app that consumes it: [aws-lambda-serverless-reference](https://github.com/FormidableLabs/aws-lambda-serverless-reference). When making changes, make sure to check out that project, make changes to the `source` of the `serverless*` modules like:

```diff
--- a/terraform/main.tf
+++ b/terraform/main.tf
@@ -12,7 +12,7 @@ terraform {
 # Base `serverless` IAM support.
 module "serverless" {
-  source = "FormidableLabs/serverless/aws"  # NORMAL from registry
+  source = "../../terraform-aws-serverless" # CHANGE to relative path
```

in every place that uses the `FormidableLabs/serverless/aws` module.

## Before submitting a PR...

Before you go ahead and submit a PR, make sure that you have done the following:

```sh
$ yarn run build
```

## Releasing a new version to Terraform Registry

_Only for project administrators_.

1. Update `CHANGELOG.md`, following format for previous versions
2. Commit as "Changes for version NUMBER"
3. Run `npm version patch` (or `minor|major|VERSION`) to run tests and lint,
   build published directories, then update `package.json` + add a git tag.
4. Run `git push && git push --tags`

TODO(REGISTRY): Add registry publishing step!!!
