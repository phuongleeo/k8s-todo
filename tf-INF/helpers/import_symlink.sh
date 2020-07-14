#!/bin/bash
for i in config.tf locals.tf terraform.tfvars variables.tf versions.tf config_helm.tf
do
 /bin/ln -sf ../$i .
done
ln -sf ../Makefile.aws.mk  Makefile
ln -sf ../../env_locals.tf env_locals.tf
