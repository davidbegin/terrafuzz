#!/bin/bash

echo "It's TerraFuzz Time"

# ./terrafuzz deploy
terraform apply -var-file=variables.tfvars

# ./terrafuzz destroy
# terraform destroy -var-file=variables.tfvars
