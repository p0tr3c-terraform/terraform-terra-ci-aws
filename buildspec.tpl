version: 0.2
env:
  variables:
    TFPLAN_NAME: ${ default_tfplan_file_name }
    TERRAGRUNT_VERSION:  ${ terragrunt_version } 
    TERRAGRUNT_CHECKSUM: ${ terragrunt_checksum }
    TERRAFORM_VERSION:   ${ terraform_version }
    TERRAFORM_CHECKSUM:  ${ terraform_checksum }
    TERRA_CI_VERSION:    ${ terra_ci_version }
    TERRA_CI_CHECKSUM:   ${ terra_ci_checksum }
    %{ if terratest_iam_role != "" }TERRATEST_IAM_ROLE: ${ terratest_iam_role }%{ endif }
  secrets-manager:
    GITHUB_TOKEN: "TerraCiGithubToken:GITHUB_TOKEN"
phases:
  install:
    commands:
      - wget -q "https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip"
      - unzip -q "terraform_$${TERRAFORM_VERSION}_linux_amd64.zip" 
      - echo -n "$${TERRAFORM_CHECKSUM}  terraform" | sha256sum --check --status
      - chmod +x ./terraform; mv terraform /usr/local/sbin/terraform
      - wget -q "https://github.com/gruntwork-io/terragrunt/releases/download/$${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"
      - mv terragrunt_linux_amd64 terragrunt
      - echo -n "$${TERRAGRUNT_CHECKSUM}  terragrunt" | sha256sum --check --status
      - chmod +x ./terragrunt; mv terragrunt /usr/local/sbin/terragrunt
      - wget -q "https://github.com/p0tr3c-terraform/terra-ci/releases/download/$${TERRA_CI_VERSION}/terra-ci-linux-amd"
      - mv terra-ci-linux-amd terra-ci
      - echo -n "$${TERRA_CI_CHECKSUM}  terra-ci" | sha256sum --check --status
      - chmod +x ./terra-ci; mv terra-ci /usr/local/sbin/terra-ci
      - git config --global url."https://oauth2:$${GITHUB_TOKEN}@github.com".insteadOf https://github.com
  pre_build:
    commands:
      - git clone $${TERRA_CI_SOURCE} $${TERRA_CI_LOCATION} && cd $${TERRA_CI_LOCATION}
%{ if terra_ci_action == "apply" ~}
      - if [ ! -z $TERRA_CI_ARTIFACT_ARN ]; then aws s3 cp "s3://$${TERRA_CI_ARTIFACT_ARN#arn:aws:s3:::}/$TFPLAN_NAME" "$(pwd)/$${TFPLAN_NAME}"; fi
      - if [ -z $TERRA_CI_ARTIFACT_ARN ]; then terra-ci workspace plan --local --path "$${TERRA_CI_RESOURCE}" "$(pwd)/$${TFPLAN_NAME}"; fi
  build:
    commands:
      - terra-ci workspace apply --local --path "$${TERRA_CI_RESOURCE}" "$(pwd)/$${TFPLAN_NAME}"
%{ endif }
%{~ if terra_ci_action == "plan" ~}
  build:
    commands:
      - terra-ci workspace plan --local --path "$${TERRA_CI_RESOURCE}" --out "$(pwd)/$${TFPLAN_NAME}"
artifacts:
  files:
    - "$${TFPLAN_NAME}"
  name: $TERRA_CI_BUILD_NAME
%{ endif }
%{~ if terra_ci_action == "test" ~}
  build:
    commands:
      - terra-ci module test --local --path "$${TERRA_CI_RESOURCE}" 
%{ endif }
