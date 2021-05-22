CURRENT_DIR := $(shell pwd)
PATH  := $(PATH):$(CURRENT_DIR)/node_modules/.bin:$(CURRENT_DIR)
SHELL := env PATH=$(PATH) /bin/bash

test_terratest_validate:
	@cd test; CGO_ENABLED=0 go test -v -run "TestValidate" -timeout 5m

test_terratest_plan:
	@cd test; CGO_ENABLED=0 go test -v -run "TestPlan" -timeout 5m

npmbin := $(shell npm bin)
snyk := $(npmbin)/snyk
$(snyk):
	@npm install snyk

test_snyk: $(snyk)
	@$(snyk) iac test *.tf --severity-threshold=medium

tfplan := tfplan.json
$(tfplan):
	@cd test; CGO_ENABLED=0 go test -v -run "TestGenerateJSONPlan" -timeout 5m
test_snyk_plan: $(snyk) $(tfplan)
	@$(snyk) iac test $(tfplan) --severity-threshold=medium

clean:
	@rm -rf node_modules
	@rm -rf package-lock.json
	@rm -rf .terraform*
