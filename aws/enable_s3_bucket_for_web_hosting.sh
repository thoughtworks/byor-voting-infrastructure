#!/usr/bin/env bash

set -e;

if [ -z "${AWS_REGION}" ]; then read -e -p "Please enter your AWS region [eu-west-1]: " inAwsRegion; else export inAwsRegion=$AWS_REGION; fi
if [ -z "$1" ]; then read -e -p "Please enter the AWS s3 bucket name: " inAwsS3BucketName; else export inAwsS3BucketName=$1; fi

awsRegion="${inAwsRegion:-eu-west-1}"
awsS3BucketName="${inAwsS3BucketName}"

set +e;

bucketstatus=$(aws s3api head-bucket --bucket ${awsS3BucketName} 2>&1)
echo ${bucketstatus}
if echo ${bucketstatus} | grep 'Not Found'; then
  echo "Bucket ${awsS3BucketName} does not exists";
else
  echo "enabling bucket ${awsS3BucketName} for static website hosting......."
  aws s3api put-bucket-website --bucket ${awsS3BucketName} --cli-input-json '{"WebsiteConfiguration": { "IndexDocument": { "Suffix": "index.html"}}}'
  echo "setting bucket ${awsS3BucketName} bucket policy to s3:GetObject=allow ......"
  aws s3api put-bucket-policy --bucket ${awsS3BucketName} --cli-input-json "{\"Policy\": \"{\\\"Version\\\":\\\"2012-10-17\\\",\\\"Statement\\\":[{\\\"Sid\\\":\\\"PublicReadGetObject\\\",\\\"Effect\\\":\\\"Allow\\\",\\\"Principal\\\":\\\"*\\\",\\\"Action\\\":\\\"s3:GetObject\\\",\\\"Resource\\\":\\\"arn:aws:s3:::${awsS3BucketName}/*\\\"}]}\"}"
fi
