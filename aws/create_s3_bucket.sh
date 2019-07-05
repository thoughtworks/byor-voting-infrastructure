#!/usr/bin/env bash

set -e;

if [ -z "${AWS_REGION}" ]; then read -e -p "Please enter your AWS region [eu-west-1]: " inAwsRegion; else export inAwsRegion=$AWS_REGION; fi
if [ -z "$1" ]; then read -e -p "Please enter the AWS s3 bucket name: " inAwsS3BucketName; else export inAwsS3BucketName=$1; fi

awsRegion="${inAwsRegion:-eu-west-1}"
awsS3BucketName="${inAwsS3BucketName}"

set +e;

bucketstatus=$(aws s3api head-bucket --bucket ${awsS3BucketName} 2>&1)

if echo ${bucketstatus} | grep 'Not Found'; then
  echo "creating bucket ${awsS3BucketName} ......."
  aws s3 mb s3://${awsS3BucketName} --region "${awsRegion}"
  echo "enabling versioning for ${awsS3BucketName} ......"
  aws s3api put-bucket-versioning --region "${awsRegion}" --bucket "${awsS3BucketName}" --versioning-configuration "Status=Enabled"
  echo "enabling encryption for ${awsS3BucketName} ......"
  aws s3api put-bucket-encryption --bucket "${awsS3BucketName}" --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
else
  echo "Bucket ${awsS3BucketName} exists";
fi
