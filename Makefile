SHELL := /bin/sh

TERRAFORM ?= terraform
SANDBOX_DIR := terraform/sandbox
TF_DATA_DIR := $(CURDIR)/$(SANDBOX_DIR)/.terraform-data
PLAN_FILE := $(CURDIR)/$(SANDBOX_DIR)/sandbox.tfplan

export TF_DATA_DIR

.PHONY: sandbox-init sandbox-validate sandbox-plan

sandbox-init:
	$(TERRAFORM) -chdir=$(SANDBOX_DIR) init -backend=false -input=false

sandbox-validate: sandbox-init
	$(TERRAFORM) -chdir=$(SANDBOX_DIR) fmt -check -diff
	$(TERRAFORM) -chdir=$(SANDBOX_DIR) validate -no-color

sandbox-plan: sandbox-validate
	$(TERRAFORM) -chdir=$(SANDBOX_DIR) plan -refresh=false -input=false -lock=false -out=$(PLAN_FILE)
	$(TERRAFORM) -chdir=$(SANDBOX_DIR) show -no-color $(PLAN_FILE)
	@printf '%s\n' 'No apply target exists. A human must review this plan and the source diff before any infrastructure-changing command.'
