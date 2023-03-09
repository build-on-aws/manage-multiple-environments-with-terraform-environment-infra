.PHONY: default validate plan apply destroy

IAM_ROLE="none"

ifeq ($(CI),"TRUE")
        echo "Do something"
endif

default:
	@echo ""
	@echo "Runs Terraform validate, plan, and apply wrapping the workspace to use"
	@echo ""
	@echo "The following commands are available:"
	@echo " - plan               : runs terraform plan for an environment"
	@echo " - apply              : runs terraform apply for an environment"
	@echo " - destroy            : will delete the entire project's infrastructure"
	@echo ""
	@echo "The "ENV" environment variable needs to be set to dev, test, or prod."
	@echo ""
	@echo "Exmple usage:"
	@echo "  EVN=dev make plan"
	@echo ""

check-env:
ifdef CI
	IAM_ROLE="Main-Branch-Infrastructure"
endif

ifdef CI_PR
	IAM_ROLE="PR-Branch-Infrastructure"
endif

validate:
	$(call check_defined, ENV, Please set the ENV to plan for. Values should be dev, test, or prod)

	@echo "Initializing Terraform ..."
	@terraform init -no-color
	
	@echo 'Creating the $(value ENV) workspace ...'
	@-terraform workspace new $(value ENV)

	@echo 'Switching to the [$(value ENV)] environment ...'
	@terraform workspace select $(value ENV)

	@terraform validate -no-color

plan:
	$(call check_defined, ENV, Please set the ENV to plan for. Values should be dev, test, or prod)

	@echo "Initializing Terraform ..."
	@terraform init -no-color
	
	@echo 'Creating the $(value ENV) workspace ...'
	@-terraform workspace new $(value ENV)

	@echo 'Switching to the [$(value ENV)] workspace ...'
	@terraform workspace select $(value ENV)

	@terraform plan  \
  	  -var-file="env_accounts_vars/$(value ENV).tfvars" -no-color -input=false


apply:
	$(call check_defined, ENV, Please set the ENV to apply. Values should be dev, test, or prod)

	@echo "Initializing Terraform ..."
	@terraform init -no-color
	
	@echo 'Creating the $(value ENV) workspace ...'
	@-terraform workspace new $(value ENV)

	@echo 'Switching to the [$(value ENV)] workspace ...'
	@terraform workspace select $(value ENV)

	@terraform apply -auto-approve -no-color -input=false \
	  -var-file="env_accounts_vars/$(value ENV).tfvars"


destroy:
	$(call check_defined, ENV, Please set the ENV to apply. Values should be dev, test, or prod)
  
	@echo "Initializing Terraform ..."
	@terraform init -no-color
	
	@echo 'Creating the $(value ENV) workspace ...'
	@-terraform workspace new $(value ENV)

	@echo 'Switching to the [$(value ENV)] workspace ...'
	@terraform workspace select $(value ENV)

	@echo "## 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥 ##"
	@echo "Are you really sure you want to completely destroy [$(value ENV)] environment ?"
	@echo "## 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥 ##"
	@read -p "Press enter to continue"
	@terraform destroy \
		-var-file="env_vars/$(value ENV).tfvars"


# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))
