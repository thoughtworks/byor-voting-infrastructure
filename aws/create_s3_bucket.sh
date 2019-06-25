#!/usr/bin/env bash

set -e;

read -e -p "Please enter the AWS region [eu-west-1]: " inAwsRegion;
awsRegion="${inAwsRegion:-eu-west-1}"

read -e -p "Please enter the AWS s3 bucket name: " inAwsS3BucketName;
awsS3BucketName="${inAwsS3BucketName}"

bucketstatus=$(aws s3api head-bucket --bucket ${awsS3BucketName} 2>&1)

if echo ${bucketstatus} | grep 'Not Found';
then
  echo "creating bucket ${awsS3BucketName} ......."
  aws s3 mb s3://${awsS3BucketName} --region "${awsRegion}"
  echo "enabling versioning for ${awsS3BucketName} ......"
  aws s3api put-bucket-versioning --region "${awsRegion}" --bucket "${awsS3BucketName}" --versioning-configuration "Status=Enabled"
  echo "enabling encryption for ${awsS3BucketName} ......"
  aws s3api put-bucket-encryption --bucket "${awsS3BucketName}" --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
else
  echo "Bucket ${awsS3BucketName} exists";
fi
