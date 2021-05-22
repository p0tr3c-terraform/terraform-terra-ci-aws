{
  "Comment": "Run Terragrunt Jobs",
  "StartAt": "Plan",
  "States": {
    "Plan": {
      "Type": "Task",
      "Resource": "arn:aws:states:::codebuild:startBuild.sync",
      "Parameters": {
        "ProjectName": "${ plan_project_name }",
        "SourceVersion.$": "$.build.sourceversion",
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
      "End": true
    }
  }
}

