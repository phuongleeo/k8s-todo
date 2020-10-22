#!/bin/bash
for i in k8s_providers.tf
do
 /bin/ln -sf ../$i .
done
