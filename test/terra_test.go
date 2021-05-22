package test

import (
	"io/ioutil"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terraform"
	terratestTesting "github.com/gruntwork-io/terratest/modules/testing"
)

func TestValidate(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		EnvVars:      map[string]string{"AWS_DEFAULT_REGION": "eu-west-1", "AWS_REGION": "eu-west-1"},
		TerraformDir: "../",
	})
	terraform.Init(t, terraformOptions)
	terraform.Validate(t, terraformOptions)
}

func TestPlan(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		EnvVars: map[string]string{"AWS_DEFAULT_REGION": "eu-west-1", "AWS_REGION": "eu-west-1"},
		Vars: map[string]interface{}{
			"repo_url":              "github.com/p0tr3c-terraform/terraform-terra-ci-aws",
			"terraform_ci_role_arn": "arn:aws:states:eu-west-1:123456789012:iam:role",
			"ssm_github_token_arn":  "arn:aws:secretsmanager:eu-west-1:123456789012:secret:test",
		},
		TerraformDir: "../",
	})
	terraform.InitAndPlan(t, terraformOptions)
}

// Adding null logger to prevent terraform plan JSON displayed in test output
type NullLogger struct{}

func (n *NullLogger) Logf(t terratestTesting.TestingT, format string, args ...interface{}) {}

func TestSnykPlan(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		EnvVars: map[string]string{"AWS_DEFAULT_REGION": "eu-west-1", "AWS_REGION": "eu-west-1"},
		Vars: map[string]interface{}{
			"repo_url":              "github.com/p0tr3c-terraform/terraform-terra-ci-aws",
			"terraform_ci_role_arn": "arn:aws:states:eu-west-1:123456789012:iam:role",
			"ssm_github_token_arn":  "arn:aws:secretsmanager:eu-west-1:123456789012:secret:test",
		},
		TerraformDir: "../",
		PlanFilePath: "tfplan",
		Logger:       logger.New(&NullLogger{}),
	})
	defer os.Remove("../tfplan")
	defer os.Remove("../tfplan.json")
	planJSONOutput := terraform.InitAndPlanAndShow(t, terraformOptions)
	if err := ioutil.WriteFile("../tfplan.json", []byte(planJSONOutput), 0644); err != nil {
		t.Fatalf("failed to write plan output: %s\n", err.Error())
	}

	makeCommand := shell.Command{
		Command: "make",
		Args: []string{
			"test_snyk_plan",
		},
		WorkingDir: "../",
	}
	shell.RunCommand(t, makeCommand)
}

func TestGenerateJSONPlan(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		EnvVars: map[string]string{"AWS_DEFAULT_REGION": "eu-west-1", "AWS_REGION": "eu-west-1"},
		Vars: map[string]interface{}{
			"repo_url":              "github.com/p0tr3c-terraform/terraform-terra-ci-aws",
			"terraform_ci_role_arn": "arn:aws:states:eu-west-1:123456789012:iam:role",
			"ssm_github_token_arn":  "arn:aws:secretsmanager:eu-west-1:123456789012:secret:test",
		},
		TerraformDir: "../",
		PlanFilePath: "tfplan",
		Logger:       logger.New(&NullLogger{}),
	})
	defer os.Remove("../tfplan")
	planJSONOutput := terraform.InitAndPlanAndShow(t, terraformOptions)
	if err := ioutil.WriteFile("../tfplan.json", []byte(planJSONOutput), 0644); err != nil {
		t.Fatalf("failed to write plan output: %s\n", err.Error())
	}
}
