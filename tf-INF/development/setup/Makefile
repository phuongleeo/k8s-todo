include terraform.tfvars

# taken from include
REGION=$(subst ",,$(aws_region))
BUCKET=$(subst ",,$(remote_state_bucket))
TERRAFORM="terraform"
# use `terraform plan | landscape` if possible
ifneq (, $(shell which landscape))
	LANDSCAPE=| landscape
endif

init:
	$(TERRAFORM) init -backend-config="region=$(REGION)" -backend-config="bucket=$(BUCKET)"

plan:
	$(TERRAFORM) get >/dev/null
	$(TERRAFORM) plan -out plan $(LANDSCAPE)

apply:
	$(TERRAFORM) apply plan && mv plan plan-`date '+%Y-%m-%d-%H-%M-%S'`

output:
	$(TERRAFORM) output

refresh:
	$(TERRAFORM) refresh

get:
	$(TERRAFORM) get

destroy:
	$(TERRAFORM) destroy

	
.PHONY: plan apply
