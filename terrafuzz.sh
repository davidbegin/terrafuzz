#!/bin/bash

function deploy {
  cd ..
  npm run build
  cd terrafuzz
  ./populate_bucket.sh
}

function destroy {
  ./empty_bucket.sh
  terraform destroy -var-file=variables.tfvars
}

function setup_terraform {
  terraform init
  terraform get
}

function apply_terraform_changes {
  terraform apply -var-file=variables.tfvars
}

function greeting {
  echo "It's Terrafuzz Time"
}

function goodbye {
  echo "You've been Terrafuzzed"
}

case "$1" in
        apply)
            greeting
            apply_terraform_changes
            deploy
            goodbye
            ;;
         
        deploy)
            greeting
            deploy
            goodbye
            ;;
         
        destroy)
            greeting
            destroy
            goodbye
            ;;
        *)
            echo $"Usage: $0 {apply|deploy|destroy|}"
            exit 1
esac
