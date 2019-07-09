
#!/usr/bin/env bash

set -e;

if [ -z "${CI}" ]; then
    tmp=..
else
    tmp=tmp
fi
BYOR_HOME=$(pwd)/$tmp/build-your-own-radar
BYOR_VOTING_INFRASTRUCTURE_HOME=$(pwd)
BYOR_VOTING_SERVER_HOME=$(pwd)/$tmp/byor-voting-server
BYOR_VOTING_WEB_APP_HOME=$(pwd)/$tmp/byor-voting-web-app

if [ -z "${CD_TARGETS}" ]; then 
    read -e -p "Please enter the targets separated by comma (i.e. prod,prod2): " targets; 
else 
    targets=$CD_TARGETS; 
fi
IFS=',' read -r -a targets_list <<< "$targets"

cd $BYOR_VOTING_INFRASTRUCTURE_HOME/tmp
echo "--[INFO] Pulling latest version of byor..."
if [[ ! -d "${BYOR_HOME}" ]]; then
    git clone https://github.com/thoughtworks/build-your-own-radar.git
fi
cd "$BYOR_HOME"
git checkout master
git pull
git fetch origin pull/101/head:pr101
git checkout pr101 | tee $BYOR_VOTING_SERVER_HOME/logs/byor.log

cd $BYOR_VOTING_INFRASTRUCTURE_HOME/tmp
echo "--[INFO] Pulling latest version of byor-voting-server..."
if [[ ! -d "${BYOR_VOTING_SERVER_HOME}" ]]; then
    git clone https://github.com/thoughtworks/byor-voting-server.git
fi
cd "$BYOR_VOTING_SERVER_HOME"
git fetch
git pull | tee logs/byor-voting-server.log

cd $BYOR_VOTING_INFRASTRUCTURE_HOME/tmp
echo "--[INFO] Pulling latest version of byor-voting-web-app..."
if [[ ! -d "${BYOR_VOTING_WEB_APP_HOME}" ]]; then
    git clone https://github.com/thoughtworks/byor-voting-web-app.git
fi
cd "$BYOR_VOTING_WEB_APP_HOME"
git fetch
git pull | tee logs/byor-voting-web-app.log

echo "--[INFO] Pulling latest version of byor-voting-infrastructure..."
cd "$BYOR_VOTING_INFRASTRUCTURE_HOME"
git fetch
git pull

for item in ${targets_list[@]}; do 
    echo "--[INFO] deploying ${item}...";
    aws/deploy_to_lambda.sh "${item}";
done
