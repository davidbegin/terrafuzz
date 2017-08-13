#!/bin/bash

clear

function upload_code_to_s3 {
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
  WEBSITE=`terraform output | awk -F"website_endpoint" '{print $2}' | sed 's/^[ \t]*=[ \t]/http:\/\//' | tr -d '[:cntrl:]' | sed 's/\[0m$//'`
  echo $WEBSITE > website.txt
}

function greeting {
  printf "\n\t\033[1;4;36mIt's Terrafuzz Time\033[0m\n"
}

function goodbye {
  printf "\n\033[1;33m...you've been Terrafuzzed\033[0m\n"
}

function open_website {
  open $(cat website.txt)
}

function deploy {
  upload_code_to_s3
  goodbye
  open_website
}

case "$1" in
        apply)
            greeting
            setup_terraform
            apply_terraform_changes
            deploy
            ;;
         
         deploy)
            greeting
            deploy
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

