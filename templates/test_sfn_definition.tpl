{
  "Comment": "Run Terratest Jobs",
  "StartAt": "Test",
  "States": {
    "Test": {
      "Type": "Task",
      "Resource": "arn:aws:states:::codebuild:startBuild.sync",
      "Parameters": {
        "ProjectName": "${ test_project_name }",
        "EnvironmentVariablesOverride": [
          {
            "Name": "TERRA_CI_BUILD_NAME",
            "Value.$": "$$.Execution.Name"
          },
          {
            "Name": "TERRA_CI_SOURCE",
            "Value.$": "$.build.environment.terra_ci_source"
          },
          {
            "Name": "TERRA_CI_LOCATION",
            "Value.$": "$.build.environment.terra_ci_location"
          },
          {
            "Name": "TERRA_CI_RESOURCE",
            "Value.$": "$.build.environment.terra_ci_resource"
          },
          {
            "Name": "TERRA_CI_RUN",
            "Value.$": "$.build.environment.terra_ci_run"
          }
        ]
      },
      "ResultPath": "$.taskresult",
      "End": true
    }
  }
}
