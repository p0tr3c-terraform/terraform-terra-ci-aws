CURRENT_DIR := $(shell pwd)
PATH  := $(PATH):$(CURRENT_DIR)/node_modules/.bin:$(CURRENT_DIR)
SHELL := env PATH=$(PATH) /bin/bash

test: test_offline

test_offline: test_terratest_offline

test_terratest_offline:
	@cd test; CGO_ENABLED=0 go test -v -run "Test.*Offline" -timeout 5m
