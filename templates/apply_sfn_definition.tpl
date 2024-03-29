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
          },
          {
            "Name": "TERRA_CI_SOURCE",
            "Value.$": "$.build.environment.terra_ci_source"
          },
          {
            "Name": "TERRA_CI_LOCATION",
            "Value.$": "$.build.environment.terra_ci_location"
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
          },
          {
            "Name": "TERRA_CI_SOURCE",
            "Value.$": "$.build.environment.terra_ci_source"
          },
          {
            "Name": "TERRA_CI_LOCATION",
            "Value.$": "$.build.environment.terra_ci_location"
          }
        ]
      },
      "ResultPath": "$.taskresult",
      "End": true
    }
  }
}

