package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestValidateOffline(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		EnvVars:      map[string]string{"AWS_DEFAULT_REGION": "eu-west-1", "AWS_REGION": "eu-west-1"},
		TerraformDir: "../",
	})
	terraform.Init(t, terraformOptions)
	terraform.Validate(t, terraformOptions)
}
