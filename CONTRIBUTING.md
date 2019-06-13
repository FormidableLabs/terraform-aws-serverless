Contributing
============

Thanks for contributing!

## Development

We develop this project using `terraform` and `yarn` / Node.js for convenience. Make sure you have both installed.

```sh
# Get terraform 0.11 (example for Mac w/ brew).
$ brew install terraform@0.11

# Install local deps
$ yarn install
```

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

### First release

_Only for Formidable employees and for the **very first release/integration only**_.

For the very first release, we need to integrate this project repository with the Terraform registry:

1. In our repository, make sure the `formidable-terraform` user has `Admin` permission.
2. Make sure you have at least one git-tagged version of the form `vX.X.X`.
3. Log in to GitHub as the user `formidable-terraform` in the 1password `Individual Contributor IC` vault.
    - **DO NOT USE YOUR PERSONAL GITHUB CREDENTIALS**: The Terraform registry requires permissions to all orgs that you have access to that are above and beyond what we're comfortable with.
4. Navigate to https://registry.terraform.io/github/create
5. Select this project by name for the field `Select Repository on GitHub` and click the `PUBLISH MODULE` button.

### On every release

_Only for project administrators_.

We need to publish a tagged version to GitHub, which then causes Terraform to do a release:

1. Update `CHANGELOG.md`, following format for previous versions
2. Commit as "Changes for version NUMBER"
3. Run `npm version patch` (or `minor|major|VERSION`) to run tests and lint,
   build published directories, then update `package.json` + add a git tag.
4. Run `git push && git push --tags`
