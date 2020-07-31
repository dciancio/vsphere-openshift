#!/usr/bin/env bash

##### Make sure to have DRS enabled to allow for creation of resource pool for the cluster

source 0_init_vars

mkdir -p $TF_VAR_cluster_id
pushd $TF_VAR_cluster_id
[ -d installer ] && rm -fr installer
cp -r ../installer .
pushd installer
terraform init
terraform apply -auto-approve -parallelism=10
if [ $? -ne 0 ]; then
  echo "ERROR:  Terraform resource creation step failed!  Please check the terraform output for more details." >&2
fi
popd
popd

