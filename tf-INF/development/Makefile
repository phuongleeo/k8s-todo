# all steps and the order they are executed in
include step_order.mk

#all-run: $(targets)
#    $(foreach dir,$(directories),(cd $(dir) && make plan && make apply) &&) :

state-prep: $(targets)
	cd state && $(MAKE) -f Makefile init plan apply
	cd ami && $(MAKE) -f Makefile init plan apply

all-plan: $(targets)
	$(foreach dir,$(directories),(cd $(dir) && make plan) &&) :

all-init:
	#$(MAKE) -f Makefile.aws.mk init
	$(foreach dir,$(directories),(cd $(dir) && make init) &&) :

all-symlink:
	#$(MAKE) -f Makefile.aws.mk init
	$(foreach dir,$(directories),(cd $(dir) && ../../helpers/import_symlink.sh) &&) :

all-clean:
	rm -rf */.terraform
	rm -rf */terraform.tfstate*
	rm -rf */plan*
