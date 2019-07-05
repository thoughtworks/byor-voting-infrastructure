#!/usr/bin/env bash

set -e;

BYOR_HOME=../build-your-own-radar
BYOR_VOTING_INFRASTRUCTURE_HOME=../byor-voting-infrastructure
BYOR_VOTING_SERVER_HOME=../byor-voting-server
BYOR_VOTING_WEB_APP_HOME=../byor-voting-web-app

AWS_SERVICE_STAGE=$1
export BYOR_ENV=$1

echo ""
echo "--[INFO] Validating configuration..."
if [ -f "${BYOR_VOTING_SERVER_HOME}/config/byor_${BYOR_ENV}.sh" ]; then
    echo "--[INFO]: server configuration already exists for environment ${BYOR_ENV}";
else
    echo "--[INFO]: creating configuration file for environment ${BYOR_ENV}";
    echo "--[INFO]: AWS";
    read -e -p "Please enter your AWS access key id: " inAwsAccessKeyid;
    read -e -p "Please enter your AWS secret access key (input hidden)" -s inAwsSecretAccesskey;
    read -e -p "Please enter your AWS region [eu-west-1]: " inAwsRegion;
    echo "--[INFO]: MongoDB Connection";
    read -e -p "Please enter your MongoDB connection string [i.e mongodb+srv://<MONGO_USER>:<MONGO_PWD>@<MONGO_SERVER>]: " inMongoUri;
    read -e -p "Please enter your MongoDB database [${BYOR_ENV}]: " inMongoDbName;
    echo "--[INFO]: MongoDB Administration-";
    read -e -p "Please enter your local MongoDB installation home path: " inMongoHome;
    read -e -p "Please enter your MongoDB host: " inMongoHost;
    read -e -p "Please enter your MongoDB username [${BYOR_ENV}-user]: " inMongoUser;
    read -e -p "Please enter your MongoDB password (input hidden): " -s inMongoPassword;
    read -e -p "Please enter your MongoDB admin database [admin]: " inMongoAuthDb;

    echo "--[INFO]: creating environment ${BYOR_ENV} configuration for server...";
    cat > "${BYOR_VOTING_SERVER_HOME}/config/byor_${BYOR_ENV}.sh" << EOL
#!/bin/bash

# aws
export AWS_SERVICE_STAGE=${AWS_SERVICE_STAGE}
export AWS_ACCESS_KEY_ID=${inAwsAccessKeyid}
export AWS_SECRET_ACCESS_KEY=${inAwsSecretAccesskey}
export AWS_REGION=${inAwsRegion:-eu-west-1}

# mongodb
# db maintenance
export MONGO_HOME=${inMongoHome}
export MONGO_HOST=${inMongoHost}
export MONGO_USER=${inMongoUser:-${BYOR_ENV}-user}
export MONGO_PWD=${inMongoPassword}
export MONGO_AUTH_DB=${inMongoAuthDb:-admin}
# app connection
export MONGO_DB_NAME=${inMongoDbName:-${BYOR_ENV}}
export MONGO_URI=${inMongoUri}
EOL
fi
if [ -f "${BYOR_VOTING_WEB_APP_HOME}/config/byor_${BYOR_ENV}.sh" ]; then
    echo "--[INFO]: web-app configuration already exists for environment ${BYOR_ENV}";
else
    echo "--[INFO]: copying environment ${BYOR_ENV} configuration from server to web-app...";
    cp "${BYOR_VOTING_SERVER_HOME}/config/byor_${BYOR_ENV}.sh" "${BYOR_VOTING_WEB_APP_HOME}/config/byor_${BYOR_ENV}.sh"
fi
source "${BYOR_VOTING_SERVER_HOME}/config/byor_${BYOR_ENV}.sh"


echo ""
echo "--[INFO] Creating AWS buckets..."
aws/create_s3_bucket.sh $AWS_SERVICE_STAGE--byor
aws/create_s3_bucket.sh $AWS_SERVICE_STAGE--byor-voting
aws/create_s3_bucket.sh $AWS_SERVICE_STAGE--byor-voting-web-app
echo ""
echo "--[INFO] Configuring AWS buckets..."
aws/enable_s3_bucket_for_web_hosting.sh $AWS_SERVICE_STAGE--byor
aws/enable_s3_bucket_for_web_hosting.sh $AWS_SERVICE_STAGE--byor-voting-web-app
echo ""
echo "--[INFO] Creating parameters in AWS Parameter Store..."
set +e;
mongoDbName=$(aws ssm get-parameter --name "${AWS_SERVICE_STAGE}ByorMongoDbName" 2>&1)
mongoUri=$(aws ssm get-parameter --name "${AWS_SERVICE_STAGE}ByorMongoUri" 2>&1)
jwtKeyStatus=$(aws ssm get-parameter --name "${AWS_SERVICE_STAGE}ByorJwtKey" 2>&1)
set -e;
if echo ${mongoDbName} | grep 'ParameterNotFound'; then
    aws ssm put-parameter --name "${AWS_SERVICE_STAGE}ByorMongoDbName" --type "String" --value $MONGO_DB_NAME --overwrite
fi
if echo ${mongoUri} | grep 'ParameterNotFound'; then
    aws ssm put-parameter --name "${AWS_SERVICE_STAGE}ByorMongoUri" --type "SecureString" --value $MONGO_URI --overwrite
fi
if echo ${jwtKeyStatus} | grep 'ParameterNotFound'; then
    echo "--[INFO] no JWT token found, creating a new one..."
    read -e -p "Please enter the JWT Key (input hidden): " -s inJwtKey;
    aws ssm put-parameter --name "${AWS_SERVICE_STAGE}ByorJwtKey" --type "SecureString" --value "${inJwtKey}" --tags "Key=initiative,Value=${AWS_SERVICE_STAGE}"
fi

echo ""
echo "--[INFO]: deploying byor-voting-server..."
cd $BYOR_VOTING_SERVER_HOME
make install
make deploy | tee byor-voting-server-deploy.log
export BACKEND_SERVICE_URL=$(cat $BYOR_VOTING_SERVER_HOME/byor-voting-server-deploy.log | grep POST | rev | cut -d' ' -f1 | rev)/
rm byor-voting-server-deploy.log

echo ""
echo "--[INFO]: deploying byor..."
# # cd $BYOR_HOME
# # git fetch origin pull/101/head:pr101
cd $BYOR_VOTING_WEB_APP_HOME
bash .make/cd/deploy_byor_aws.sh $BYOR_HOME
export RADAR_SERVICE_URL=http://${AWS_SERVICE_STAGE}--byor.s3-website-${AWS_REGION}.amazonaws.com/

echo ""
echo "--[INFO]: deploying byor..."
echo "--[INFO]: BACKEND_SERVICE_URL=${BACKEND_SERVICE_URL}"
echo "--[INFO]: RADAR_SERVICE_URL=${RADAR_SERVICE_URL}"

make install
make build
make deploy

echo "--[INFO]: BYOR-Voting-Web-App available at http://${AWS_SERVICE_STAGE}--byor-voting-web-app.s3-website-${AWS_REGION}.amazonaws.com/"


# ## administrative tasks
# cd $BYOR_VOTING_SERVER_HOME

echo ""
echo "--[INFO]: validating db..."
# make validate_db
# # Do you want to fix the errors? [y/N] n
# # Please enter a target environment [local-dev]: twau


echo ""
echo "--[INFO]: reset admin password..."
# make set_admin_user_and_pwd
# # This will override the existing user name and password for the admin user... are you sure to continue? [y/N] y
# # Please enter a target environment [local-dev]: twau
# # Please enter old admin user name [admin]: abc

# make dump_db
# # Please enter a target environment [local-dev]: twau
# # Please enter folder where to store the dump [../dump]:
