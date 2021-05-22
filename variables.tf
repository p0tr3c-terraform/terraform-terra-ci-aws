variable "aws_region" {
  default = "eu-west-1"
}

variable "serial_number" {
  default = "00000000"
}

variable "repo_url" {}
variable "terraform_ci_role_arn" {}

variable "default_tfplan_file_name" {
  default = "tfplan"
}

variable "terragrunt_version" {
  default = "v0.29.0"
}

variable "terragrunt_checksum" {
  default = "b46c0dae9469cb1633d0e3d71092bce43581b979dcbbb1c14aac96a4e3f39935"
}

variable "terraform_version" {
  default = "0.15.0"
}

variable "terraform_checksum" {
  default = "e839f502334be98262384b07c59c422d6219139c1bb7012aba24957633d077b6"
}

variable "terra_ci_version" {
  default = "v0.8.4"
}

variable "terra_ci_checksum" {
  default = "6f2e6ce2c95c6926d15331f1e769bd5ff6c0098a6f11743648451e9ecd88f8dd"
}

variable "create_artifact_bucket" {
  default = true
}

variable "enable_artifacts" {
  default = true
}

variable "terra_ci_job_name" {
  default = "terra_ci_job"
}

variable "ci_job_role_name" {
  default = "terra_ci_job"
}

variable "artifact_bucket_name" {
  default = "terra-ci-artifacts"
}

variable "artifact_bucket_arn" {
  default = ""
}

variable "terra_ci_plan_name" {
  default = "terra-ci-plan-runner"
}

variable "terra_ci_plan_timeout" {
  default = "30"
}

variable "terra_ci_apply_name" {
  default = "terra-ci-apply-runner"
}

variable "terra_ci_apply_timeout" {
  default = "30"
}

variable "terra_ci_test_name" {
  default = "terra-ci-test-runner"
}

variable "terra_ci_test_timeout" {
  default = "30"
}

variable "terra_ci_sfn_iam_role_name" {
  default = "terra_ci_runner"
}

variable "terra_ci_plan_sfn_name" {
  default = "terra-ci-plan-runner"
}

variable "terra_ci_apply_sfn_name" {
  default = "terra-ci-apply-runner"
}

variable "terra_ci_test_sfn_name" {
  default = "terra-ci-test-runner"
}

variable "terratest_iam_role" {
  default = ""
}

variable "ssm_github_token_arn" {}
