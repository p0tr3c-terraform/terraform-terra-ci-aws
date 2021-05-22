resource "aws_iam_role" "terra_ci_job" {
  name = var.ci_job_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "terra_ci_job" {
  role = aws_iam_role.terra_ci_job.name

  policy = templatefile("${path.module}/templates/ci_iam_role_policy.tpl", {
    terraform_ci_role_arn = var.terraform_ci_role_arn,
    artifact_bucket_arn   = var.create_artifact_bucket ? aws_s3_bucket.terra_ci[0].arn : var.artifact_bucket_arn,
    ssm_github_token_arn  = var.ssm_github_token_arn
  })
}

resource "aws_s3_bucket" "terra_ci" {
  count  = var.create_artifact_bucket ? 1 : 0
  bucket = "${var.artifact_bucket_name}-${var.aws_region}-${var.serial_number}"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = false

      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
  lifecycle_rule {
    expiration {
      days = 1
    }

    id      = "artifacts"
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "terra_ci_bucket_acl" {
  count  = var.create_artifact_bucket ? 1 : 0
  bucket = aws_s3_bucket.terra_ci[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


################ ARTIFACTS ENABLED  ########################

resource "aws_codebuild_project" "terra_ci_plan" {
  count         = var.enable_artifacts ? 1 : 0
  name          = var.terra_ci_plan_name
  description   = "Deploy environment configuration"
  build_timeout = var.terra_ci_plan_timeout
  service_role  = aws_iam_role.terra_ci_job.arn

  artifacts {
    type                   = "S3"
    location               = var.create_artifact_bucket ? aws_s3_bucket.terra_ci[0].id : var.artifact_bucket_arn
    override_artifact_name = true
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec = templatefile("${path.module}/templates/buildspec.tpl", {
      default_tfplan_file_name = var.default_tfplan_file_name,
      terragrunt_version       = var.terragrunt_version,
      terragrunt_checksum      = var.terragrunt_checksum,
      terraform_version        = var.terraform_version,
      terraform_checksum       = var.terraform_checksum,
      terra_ci_version         = var.terra_ci_version,
      terra_ci_checksum        = var.terra_ci_checksum,
      terratest_iam_role       = var.terratest_iam_role,
      enable_artifacts         = true,
      terra_ci_action          = "plan",
      extra_secret_envs        = var.extra_secret_envs
    })
    type = "NO_SOURCE"
  }
}

resource "aws_codebuild_project" "terra_ci_apply" {
  count         = var.enable_artifacts ? 1 : 0
  name          = var.terra_ci_apply_name
  description   = "Deploy environment configuration"
  build_timeout = var.terra_ci_apply_timeout
  service_role  = aws_iam_role.terra_ci_job.arn

  artifacts {
    type                   = "S3"
    location               = var.create_artifact_bucket ? aws_s3_bucket.terra_ci[0].id : var.artifact_bucket_arn
    override_artifact_name = true
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec = templatefile("${path.module}/templates/buildspec.tpl", {
      default_tfplan_file_name = var.default_tfplan_file_name,
      terragrunt_version       = var.terragrunt_version,
      terragrunt_checksum      = var.terragrunt_checksum,
      terraform_version        = var.terraform_version,
      terraform_checksum       = var.terraform_checksum,
      terra_ci_version         = var.terra_ci_version,
      terra_ci_checksum        = var.terra_ci_checksum,
      terratest_iam_role       = var.terratest_iam_role,
      enable_artifacts         = true,
      terra_ci_action          = "apply",
      extra_secret_envs        = var.extra_secret_envs
    })
    type = "NO_SOURCE"
  }
}

resource "aws_codebuild_project" "terra_ci_test" {
  count         = var.enable_artifacts ? 1 : 0
  name          = var.terra_ci_test_name
  description   = "Run terratest"
  build_timeout = var.terra_ci_test_timeout
  service_role  = aws_iam_role.terra_ci_job.arn

  artifacts {
    type                   = "S3"
    location               = var.create_artifact_bucket ? aws_s3_bucket.terra_ci[0].id : var.artifact_bucket_arn
    override_artifact_name = true
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec = templatefile("${path.module}/templates/buildspec.tpl", {
      default_tfplan_file_name = var.default_tfplan_file_name,
      terragrunt_version       = var.terragrunt_version,
      terragrunt_checksum      = var.terragrunt_checksum,
      terraform_version        = var.terraform_version,
      terraform_checksum       = var.terraform_checksum,
      terra_ci_version         = var.terra_ci_version,
      terra_ci_checksum        = var.terra_ci_checksum,
      terratest_iam_role       = var.terratest_iam_role,
      enable_artifacts         = true,
      terra_ci_action          = "test",
      extra_secret_envs        = var.extra_secret_envs
    })
    type = "NO_SOURCE"
  }
}

################ ARTIFACTS DISABLED  ########################

resource "aws_codebuild_project" "terra_ci_plan_no_artifact" {
  count         = var.enable_artifacts ? 0 : 1
  name          = var.terra_ci_plan_name
  description   = "Deploy environment configuration"
  build_timeout = var.terra_ci_plan_timeout
  service_role  = aws_iam_role.terra_ci_job.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec = templatefile("${path.module}/templates/buildspec.tpl", {
      default_tfplan_file_name = var.default_tfplan_file_name,
      terragrunt_version       = var.terragrunt_version,
      terragrunt_checksum      = var.terragrunt_checksum,
      terraform_version        = var.terraform_version,
      terraform_checksum       = var.terraform_checksum,
      terra_ci_version         = var.terra_ci_version,
      terra_ci_checksum        = var.terra_ci_checksum,
      terratest_iam_role       = var.terratest_iam_role,
      enable_artifacts         = false,
      terra_ci_action          = "plan",
      extra_secret_envs        = var.extra_secret_envs
    })
    type = "NO_SOURCE"
  }
}

resource "aws_codebuild_project" "terra_ci_apply_no_artifact" {
  count         = var.enable_artifacts ? 0 : 1
  name          = var.terra_ci_apply_name
  description   = "Deploy environment configuration"
  build_timeout = var.terra_ci_apply_timeout
  service_role  = aws_iam_role.terra_ci_job.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec = templatefile("${path.module}/templates/buildspec.tpl", {
      default_tfplan_file_name = var.default_tfplan_file_name,
      terragrunt_version       = var.terragrunt_version,
      terragrunt_checksum      = var.terragrunt_checksum,
      terraform_version        = var.terraform_version,
      terraform_checksum       = var.terraform_checksum,
      terra_ci_version         = var.terra_ci_version,
      terra_ci_checksum        = var.terra_ci_checksum,
      terratest_iam_role       = var.terratest_iam_role,
      enable_artifacts         = false,
      terra_ci_action          = "apply",
      extra_secret_envs        = var.extra_secret_envs
    })

    type = "NO_SOURCE"
  }
}

resource "aws_codebuild_project" "terra_ci_test_no_artifact" {
  count         = var.enable_artifacts ? 0 : 1
  name          = var.terra_ci_test_name
  description   = "Run terratest"
  build_timeout = var.terra_ci_test_timeout
  service_role  = aws_iam_role.terra_ci_job.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec = templatefile("${path.module}/templates/buildspec.tpl", {
      default_tfplan_file_name = var.default_tfplan_file_name,
      terragrunt_version       = var.terragrunt_version,
      terragrunt_checksum      = var.terragrunt_checksum,
      terraform_version        = var.terraform_version,
      terraform_checksum       = var.terraform_checksum,
      terra_ci_version         = var.terra_ci_version,
      terra_ci_checksum        = var.terra_ci_checksum,
      terratest_iam_role       = var.terratest_iam_role,
      enable_artifacts         = false,
      terra_ci_action          = "test",
      extra_secret_envs        = var.extra_secret_envs
    })
    type = "NO_SOURCE"
  }
}
