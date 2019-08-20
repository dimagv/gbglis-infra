#!/bin/bash

BRANCH=$1
USERNAME=$2
PAT=$3

JENKINS_URL="http://192.168.161.240:8320"
BASE_URL="http://192.168.160.166:8080/tfs/DMDL/"
REPO_URL=$BASE_URL+"_git/GBGLIS"
HOOK_URL=$BASE_URL+"_apis/hooks/subscriptions"


echo "up branch: ${BRANCH}"
echo "username: ${USERNAME}"
echo "password: ${PAT}"

service_hook_data() {
  cat <<EOF
{
  "publisherId": "tfs",
  "eventType": "git.push",
  "consumerId": "jenkins",
  "consumerActionId": "triggerGenericBuild",
  "publisherInputs": {
    "branch": $BRANCH,
    "projectId": "327ebaa7-1ccd-48e3-90d5-96f8caa03664",
    "repository": "5fd70a75-7cc0-4596-9089-a84966188769",
  },
  "consumerInputs": {
    "buildName": "GBGLIS/$BRANCH",
    "serverBaseUrl": $JENKINS_URL,
    "username": "admin",
    "useTfsPlugin": "built-in",
    "password": "admin"
  },
}
EOF
}

service_hook_data
echo $HOOK_URL

curl -i -H "Accept: application/json; api-version=1.0" -H "Content-Type:application/json" --data "$(service_hook_data)" -XPOST -u :$PAT $HOOK_URL --location


#cd /home/ironjab/gbgliscicd
#git -c http.extraheader="AUTHORIZATION: Basic $(echo -n $USERNAME:$PAT |base64 -w0)" clone -b $BRANCH --single-branch $REPO_URL $BRANCH
#cd $BRANCH
#ls -la