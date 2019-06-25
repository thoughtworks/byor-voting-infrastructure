#!/usr/bin/env bash

aws_region=eu-west-1

echo "Initializing Terraform configuration ............."
terraform init
echo "Creating Terraform execution plan ............."
terraform plan
exit_code=$?

if [ $exit_code -eq 0 ]; then
    read -p "Do you want to run Terraform apply [Y,N]" input
fi
if [ "$input" = "Y" ] || [ "$input" = "y" ]
then
    echo "Applying changes to reach desired state ............."
    terraform apply -lock=true
else
    echo "Exit......."
fi
