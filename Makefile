CURRENT_DIR := $(shell pwd)
PATH  := $(PATH):$(CURRENT_DIR)/node_modules/.bin:$(CURRENT_DIR)
SHELL := env PATH=$(PATH) /bin/bash

test: test_offline test_compliance

test_offline: test_terratest_offline

test_terratest_offline:
	@cd test; CGO_ENABLED=0 go test -v -run "Test.*Offline" -timeout 5m

test_terratest_plan:
	@cd test; CGO_ENABLED=0 go test -v -run "TestPlan" -timeout 5m

test_compliance: test_snyk test_snyk_plan

npmbin := $(shell npm bin)
snyk := $(npmbin)/snyk
$(snyk):
	@npm install snyk

test_snyk: $(snyk)
	@$(snyk) iac test *.tf --severity-threshold=medium

test_snyk_plan: $(snyk)
	@$(snyk) iac test tfplan.json --severity-threshold=medium

clean:
	@rm -rf node_modules
	@rm -rf package-lock.json
	@rm -rf .terraform*
