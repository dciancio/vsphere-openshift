#!/usr/bin/env bash

source 0_init_vars

pushd $TF_VAR_cluster_id/installer
terraform destroy -auto-approve -parallelism=10
if [ $? -ne 0 ]; then
  echo "ERROR:  Terraform resource destroy step failed!  Please check the terraform output for more details." >&2
fi
popd

