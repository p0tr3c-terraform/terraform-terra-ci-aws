{
  "Comment": "Run Terragrunt Jobs",
  "StartAt": "Plan",
  "States": {
    "Plan": {
      "Type": "Task",
      "Resource": "arn:aws:states:::codebuild:startBuild.sync",
      "Parameters": {
        "ProjectName": "${ plan_project_name }",
        "EnvironmentVariablesOverride": [
          {
            "Name": "TERRA_CI_BUILD_NAME",
            "Value.$": "$$.Execution.Name"
          },
          {
            "Name": "TERRA_CI_RESOURCE",
            "Value.$": "$.build.environment.terra_ci_resource"
          }
        ]
      },
      "ResultPath": "$.taskresult",
      "Next": "Apply"
    },
    "Apply": {
      "Type": "Task",
      "Resource": "arn:aws:states:::codebuild:startBuild.sync",
      "Parameters": {
        "ProjectName": "${ apply_project_name }",
        "EnvironmentVariablesOverride": [
          {
            "Name": "TERRA_CI_ARTIFACT_ARN",
            "Value.$": "$.taskresult.Build.Artifacts.Location"
          },
          {
            "Name": "TERRA_CI_BUILD_NAME",
            "Value.$": "$$.Execution.Name"
          },
          {
            "Name": "TERRA_CI_RESOURCE",
            "Value.$": "$.build.environment.terra_ci_resource"
          }
        ]
      },
      "End": true
    }
  }
}

