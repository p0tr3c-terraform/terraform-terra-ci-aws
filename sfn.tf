resource "aws_iam_role" "terra_ci_runner" {
  name = var.terra_ci_sfn_iam_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "terra_ci_runner" {
  role = aws_iam_role.terra_ci_runner.name

  policy = templatefile("${path.module}/templates/sfn_iam_policy.tpl", {
    plan_arn           = var.enable_artifacts ? aws_codebuild_project.terra_ci_plan[0].arn : aws_codebuild_project.terra_ci_plan_no_artifact[0].arn,
    apply_arn          = var.enable_artifacts ? aws_codebuild_project.terra_ci_apply[0].arn : aws_codebuild_project.terra_ci_apply_no_artifact[0].arn,
    test_arn           = var.enable_artifacts ? aws_codebuild_project.terra_ci_test[0].arn : aws_codebuild_project.terra_ci_test_no_artifact[0].arn,
    sfn_event_role_arn = "arn:aws:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventForCodeBuildStartBuildRule"
  })
}

resource "aws_sfn_state_machine" "terra_ci_plan_runner" {
  name     = var.terra_ci_plan_sfn_name
  role_arn = aws_iam_role.terra_ci_runner.arn

  definition = templatefile("${path.module}/templates/plan_sfn_definition.tpl", {
    plan_project_name = var.enable_artifacts ? aws_codebuild_project.terra_ci_plan[0].name : aws_codebuild_project.terra_ci_plan_no_artifact[0].name
  })
}

resource "aws_sfn_state_machine" "terra_ci_apply_runner" {
  name     = var.terra_ci_apply_sfn_name
  role_arn = aws_iam_role.terra_ci_runner.arn

  definition = templatefile("${path.module}/templates/apply_sfn_definition.tpl", {
    plan_project_name  = var.enable_artifacts ? aws_codebuild_project.terra_ci_plan[0].name : aws_codebuild_project.terra_ci_plan_no_artifact[0].name
    apply_project_name = var.enable_artifacts ? aws_codebuild_project.terra_ci_apply[0].name : aws_codebuild_project.terra_ci_apply_no_artifact[0].name
  })
}

resource "aws_sfn_state_machine" "terra_ci_test_runner" {
  name     = var.terra_ci_test_sfn_name
  role_arn = aws_iam_role.terra_ci_runner.arn

  definition = templatefile("${path.module}/templates/test_sfn_definition.tpl", {
    test_project_name = var.enable_artifacts ? aws_codebuild_project.terra_ci_test[0].name : aws_codebuild_project.terra_ci_test_no_artifact[0].name
  })
}

output "terra_ci_plan_arn" {
  value = aws_sfn_state_machine.terra_ci_plan_runner.arn
}

output "terra_ci_apply_arn" {
  value = aws_sfn_state_machine.terra_ci_apply_runner.arn
}

output "terra_ci_test_arn" {
  value = aws_sfn_state_machine.terra_ci_test_runner.arn
}
