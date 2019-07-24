#!/usr/bin/env bash

set -e;

echo "--[INFO] setting projects locations..."
if [ -z "${CI}" ]; then
    tmp=..
else
    tmp=tmp
fi
BYOR_HOME=$(pwd)/${tmp}/build-your-own-radar
BYOR_VOTING_INFRASTRUCTURE_HOME=$(pwd)
BYOR_VOTING_SERVER_HOME=$(pwd)/${tmp}/byor-voting-server
BYOR_VOTING_WEB_APP_HOME=$(pwd)/${tmp}/byor-voting-web-app


echo "--[INFO] setting targets..."
if [ -z $1 ]; then
    if [ -z "${CD_TARGETS}" ]; then 
        read -e -p "Please enter the targets separated by comma (i.e. prod,prod2): " targets; 
    else 
        targets=${CD_TARGETS}; 
    fi
else
    targets=$1
fi
IFS=',' read -r -a targets_list <<< "${targets}"


echo "--[INFO] pulling latest changes..."
cd ${BYOR_VOTING_INFRASTRUCTURE_HOME}/tmp
echo "--[INFO] Pulling latest version of byor..."
if [[ ! -d "${BYOR_HOME}" ]]; then
    git clone https://github.com/thoughtworks/build-your-own-radar.git
fi
cd "${BYOR_HOME}"
git checkout master
git pull
git fetch origin pull/101/head:pr101
git checkout pr101 | tee ${BYOR_VOTING_INFRASTRUCTURE_HOME}/logs/byor.log

cd ${BYOR_VOTING_INFRASTRUCTURE_HOME}/tmp
echo "--[INFO] Pulling latest version of byor-voting-server..."
if [[ ! -d "${BYOR_VOTING_SERVER_HOME}" ]]; then
    git clone https://github.com/thoughtworks/byor-voting-server.git
fi
cd "${BYOR_VOTING_SERVER_HOME}"
git fetch
git pull | tee ${BYOR_VOTING_INFRASTRUCTURE_HOME}/logs/byor-voting-server.log

cd ${BYOR_VOTING_INFRASTRUCTURE_HOME}/tmp
echo "--[INFO] Pulling latest version of byor-voting-web-app..."
if [[ ! -d "${BYOR_VOTING_WEB_APP_HOME}" ]]; then
    git clone https://github.com/thoughtworks/byor-voting-web-app.git
fi
cd "${BYOR_VOTING_WEB_APP_HOME}"
git fetch
git pull | tee logs/byor-voting-web-app.log

echo "--[INFO] Pulling latest version of byor-voting-infrastructure..."
cd "${BYOR_VOTING_INFRASTRUCTURE_HOME}"
git fetch
git pull


echo "--[INFO] deploying to targets..."
for target in ${targets_list[@]}; do 
    echo "--[INFO] deploying to target: ${target}...";


###### setting environment variables...
    export AWS_SERVICE_STAGE=${target}
    export BYOR_ENV=${target}
    CONFIG_FILE="${BYOR_VOTING_INFRASTRUCTURE_HOME}/config/byor_${BYOR_ENV}.sh"


    echo ""
    if [ -z "${CI}" ]; then
        echo "--[INFO] Validating configuration..."
        if [ -f ${CONFIG_FILE} ]; then
            echo "--[INFO]: configuration already exists for environment ${BYOR_ENV}";
        else
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

            echo "--[INFO]: creating configuration file for environment ${BYOR_ENV}...";
            cat > ${CONFIG_FILE} << EOL
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
# app services
# export BACKEND_SERVICE_URL=
# export RADAR_SERVICE_URL=
# export WEB_APP_URL=
EOL
        fi
        echo "--[INFO]: copying environment ${BYOR_ENV} configuration to server...";
        cp ${CONFIG_FILE} "${BYOR_VOTING_SERVER_HOME}/config/byor_${BYOR_ENV}.sh"
        echo "--[INFO]: copying environment ${BYOR_ENV} configuration to web-app...";
        cp ${CONFIG_FILE} "${BYOR_VOTING_WEB_APP_HOME}/config/byor_${BYOR_ENV}.sh"
        source ${CONFIG_FILE}
    fi
    export AWS_DEFAULT_REGION=${AWS_REGION}


    echo "--[INFO] configuring AWS S3 buckets..."
    echo "--[INFO] Creating AWS buckets..."
    aws/create_s3_bucket.sh ${AWS_SERVICE_STAGE}--byor
    aws/create_s3_bucket.sh ${AWS_SERVICE_STAGE}--byor-voting
    aws/create_s3_bucket.sh ${AWS_SERVICE_STAGE}--byor-voting-web-app
    echo ""
    echo "--[INFO] Configuring AWS buckets..."
    aws/enable_s3_bucket_for_web_hosting.sh ${AWS_SERVICE_STAGE}--byor
    aws/enable_s3_bucket_for_web_hosting.sh ${AWS_SERVICE_STAGE}--byor-voting-web-app
    echo ""
    echo "--[INFO] Creating parameters in AWS Parameter Store..."
    set +e;
    mongoDbName=$(aws ssm get-parameter --name "${AWS_SERVICE_STAGE}ByorMongoDbName" 2>&1)
    mongoUri=$(aws ssm get-parameter --name "${AWS_SERVICE_STAGE}ByorMongoUri" 2>&1)
    jwtKeyStatus=$(aws ssm get-parameter --name "${AWS_SERVICE_STAGE}ByorJwtKey" 2>&1)
    set -e;
    if echo ${mongoDbName} | grep 'ParameterNotFound'; then
        aws ssm put-parameter --name "${AWS_SERVICE_STAGE}ByorMongoDbName" --type "String" --value ${MONGO_DB_NAME} --overwrite
    fi
    if echo ${mongoUri} | grep 'ParameterNotFound'; then
        aws ssm put-parameter --name "${AWS_SERVICE_STAGE}ByorMongoUri" --type "SecureString" --value ${MONGO_URI} --overwrite
    fi
    if echo ${jwtKeyStatus} | grep 'ParameterNotFound'; then
        echo "--[INFO] no JWT token found, creating a new one..."
        read -e -p "Please enter the JWT Key (input hidden): " -s inJwtKey;
        aws ssm put-parameter --name "${AWS_SERVICE_STAGE}ByorJwtKey" --type "SecureString" --value "${inJwtKey}" --tags "Key=initiative,Value=${AWS_SERVICE_STAGE}"
    fi


    echo ""
    echo "--[INFO]: deploying byor-voting-server..."
    cd "${BYOR_VOTING_SERVER_HOME}"
    /bin/bash .make/utils/execute-in-docker.sh -s "byor-voting-server" -o "--no-start"
    docker cp . $(docker-compose ps -q byor-voting-server):/usr/src/app/
    make install | tee logs/byor-voting-server-install.log
    make deploy | tee logs/byor-voting-server-deploy.log
    if cat ${BYOR_VOTING_SERVER_HOME}/logs/byor-voting-server-deploy.log | grep "exited with code 1"; then
        echo "--[ERROR]: serverless deployment failed!"
        exit 1;
    fi
    export BACKEND_SERVICE_URL=$(cat ${BYOR_VOTING_SERVER_HOME}/logs/byor-voting-server-deploy.log | grep POST | rev | cut -d' ' -f1 | rev)/
    if [ -z "${CI}" ]; then
        awk '// { sub(/^# export BACKEND_SERVICE_URL=.*/,"# export BACKEND_SERVICE_URL="ENVIRON["BACKEND_SERVICE_URL"]); print }' ${CONFIG_FILE} > tmp.tmp && mv tmp.tmp ${CONFIG_FILE}
    fi


    echo ""
    echo "--[INFO]: deploying byor..."
    cd "${BYOR_VOTING_WEB_APP_HOME}"
    bash .make/cd/deploy_byor_aws.sh ${BYOR_HOME} | tee logs/byor-deploy.log
    export RADAR_SERVICE_URL=http://${AWS_SERVICE_STAGE}--byor.s3-website-${AWS_REGION}.amazonaws.com/
    if [ -z "${CI}" ]; then
        awk '// { sub(/^# export RADAR_SERVICE_URL=.*/,"# export RADAR_SERVICE_URL="ENVIRON["RADAR_SERVICE_URL"]); print }' ${CONFIG_FILE} > tmp.tmp && mv tmp.tmp ${CONFIG_FILE}
    fi


    echo ""
    echo "--[INFO]: deploying byor-voting-web-app..."
    echo "--[INFO]: BACKEND_SERVICE_URL=${BACKEND_SERVICE_URL}"
    echo "--[INFO]: RADAR_SERVICE_URL=${RADAR_SERVICE_URL}"
    /bin/bash .make/utils/execute-in-docker.sh -s "byor-voting-web-app" -o "--no-start"
    docker cp . $(docker-compose ps -q byor-voting-web-app):/usr/src/app/
    make install | tee logs/byor-voting-web-app-install.log
    make build | tee logs/byor-voting-web-app-build.log
    make deploy | tee logs/byor-voting-web-app-deploy.log
    export WEB_APP_URL=http://${AWS_SERVICE_STAGE}--byor-voting-web-app.s3-website-${AWS_REGION}.amazonaws.com/
    echo "--[INFO]: byor-voting-web-app available at ${WEB_APP_URL}"
    if [ -z "${CI}" ]; then
        awk '// { sub(/^# export WEB_APP_URL=.*/,"# export WEB_APP_URL="ENVIRON["WEB_APP_URL"]); print }' ${CONFIG_FILE} > tmp.tmp && mv tmp.tmp ${CONFIG_FILE}
    fi


###### performing administrative tasks...
    # cd "${BYOR_VOTING_SERVER_HOME}"

    # echo ""
    # echo "--[INFO]: validating db..."
    # make validate_db
    # # Do you want to fix the errors? [y/N] n
    # # Please enter a target environment [local-dev]: twau


    # echo ""
    # echo "--[INFO]: reset admin password..."
    # make set_admin_user_and_pwd
    # # This will override the existing user name and password for the admin user... are you sure to continue? [y/N] y
    # # Please enter a target environment [local-dev]: twau
    # # Please enter old admin user name [admin]: abc

    # make dump_db
    # # Please enter a target environment [local-dev]: twau
    # # Please enter folder where to store the dump [../dump]:
done