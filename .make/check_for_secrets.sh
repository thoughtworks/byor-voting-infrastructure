#!/bin/bash
set -e;

echo "About to run secret disclosure checks with Talisman..."

docker run \
       --rm \
       -v "$PWD:/usr/src" \
       -v /usr/src/.git/ \
       -v /usr/src/.terraform/plugins \
       -v /usr/src/.terraform/modules \
       -v /usr/src/config \
       -v /usr/src/logs \
       -v /usr/src/output \
       byoritaly/talisman-checks-runner:0.4.6 \
       /bin/bash -c "git init &> /dev/null && talisman --pattern \"**\""

echo "...no secrets found, ok!"
