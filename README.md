# terraform-terra-ci-aws
Terraform CI running in AWS Step Functions

## Usage

```
module "terra_ci" {
  source                = "github.com/p0tr3c-terraform/terraform-terra-ci-aws"
  aws_region            = var.aws_region
  serial_number         = var.serial_number
  repo_url              = var.repo_url
  ssm_github_token_arn  = var.ssm_github_token_arn
  terratest_iam_role    = var.terratest_iam_role
  terraform_ci_role_arn = var.terraform_ci_role_arn
}

output "terra_ci_plan_arn" {
  value = module.terra_ci.terra_ci_plan_arn
}

output "terra_ci_apply_arn" {
  value = module.terra_ci.terra_ci_apply_arn
}

output "terra_ci_test_arn" {
  value = module.terra_ci.terra_ci_test_arn
}
```
