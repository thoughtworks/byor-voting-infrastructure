#!/usr/bin/env bash

set -e;

BYOR_VOTING_INFRASTRUCTURE_HOME=$(pwd)


##### configuring terraform
cd "$BYOR_VOTING_INFRASTRUCTURE_HOME"
echo "--[INFO]: configuring Terraform....";
if [[ ! -f terraform.tf ]]; then
    echo "--[INFO]: configuring terraform.tf";
    cp terraform.tf.sample terraform.tf
    read -e -p "Please enter your AWS region [eu-west-1]: " inAwsRegion;
    read -e -p "Please enter the AWS S3 bucket where to store terraform state [byor-terraform-state-storage]: " inAwsS3TerraformState;
    export AWS_REGION="${inAwsRegion:-eu-west-1}"
    export inAwsS3TerraformState="${inAwsS3TerraformState:-byor-terraform-state-storage}"
    awk '// { sub(/<terraform-state-storage>/,ENVIRON["inAwsS3TerraformState"]); print }' terraform.tf > tmp.tmp && mv tmp.tmp terraform.tf
    awk '// { sub(/<region>/,ENVIRON["AWS_REGION"]); print }' terraform.tf > tmp.tmp && mv tmp.tmp terraform.tf
else
    export inAwsS3TerraformState=$(cat terraform.tf | grep bucket | rev | cut -d' ' -f1 | rev | tr -d '"')
    export AWS_REGION=$(cat terraform.tf | grep region | rev | cut -d' ' -f1 | rev | tr -d '"')
fi
if [[ ! -f terraform.tfvars ]]; then
    echo "--[INFO]: configuring terraform.tfvars";
    cp terraform.tfvars.sample terraform.tfvars
    read -e -p "Please enter your AWS access key id: " inAwsAccessKeyid;
    read -e -p "Please enter your AWS secret access key (input hidden)" -s inAwsSecretAccesskey;
    if [ -z inAwsRegion ]; then
        read -e -p "Please enter your AWS region [eu-west-1]: " inAwsRegion;
        export AWS_REGION="${inAwsRegion:-eu-west-1}"
    fi
    export inAwsAccessKeyid=$inAwsAccessKeyid
    export inAwsSecretAccesskey=$inAwsSecretAccesskey
    awk '// { sub(/<aws_access_key>/,ENVIRON["inAwsAccessKeyid"]); print }' terraform.tfvars > tmp.tmp && mv tmp.tmp terraform.tfvars
    awk '// { sub(/<aws_secret_key>/,ENVIRON["inAwsSecretAccesskey"]); print }' terraform.tfvars > tmp.tmp && mv tmp.tmp terraform.tfvars
    awk '// { sub(/<aws_zones>/,ENVIRON["AWS_REGION"]); print }' terraform.tfvars > tmp.tmp && mv tmp.tmp terraform.tfvars
fi
if [[ ! -f variables.tf ]]; then
    echo "--[INFO]: configuring variables.tf";
    cp variables.tf.sample variables.tf
    read -e -p "Please enter AMI id for the EKS node: " inAwsAmiId;
    read -e -p "Please enter EC2 Key Pair name: " inAwsEc2KeyPairName;
    export inAwsAmiId=$inAwsAmiId
    export inAwsEc2KeyPairName=$inAwsEc2KeyPairName
    awk '// { sub(/<AMI-ID>/,ENVIRON["inAwsAmiId"]); print }' variables.tf > tmp.tmp && mv tmp.tmp variables.tf
    awk '// { sub(/<keypair name>/,ENVIRON["inAwsEc2KeyPairName"]); print }' variables.tf > tmp.tmp && mv tmp.tmp variables.tf
    read -e -p "Do you want stop the script and review the other parameters inside variables.tf? [y/N] " response;
    if [[ ! ${response} == y ]]; then
        echo "Aborting on user choice"
        exit 1;
    fi
fi


##### configuring aws s3 bucket...
echo ""
echo "--[INFO] Creating AWS bucket..."
aws/create_s3_bucket.sh $inAwsS3TerraformState
echo "--[INFO] Configuring AWS bucket..."
# aws/enable_s3_bucket_for_web_hosting.sh $AWS_SERVICE_STAGE--byor


##### provisioning the cluster...
echo ""
echo "--[INFO] Initializing Terraform..."
terraform init
echo "--[INFO] Cheking Terraform configuration..."
terraform plan
echo "--[INFO] Provisioning Kubernetes cluster..."
terraform apply

##### installing Isto, Cert-Manager, Kiali secrets, and Let's encrypt secrets...
# echo ""
# echo "--[INFO] Installing Isto, Cert-Manager, Kiali secrets, and Let's encrypt secrets..."
# source k8s/k8s_setup.sh