#!/bin/bash

BRANCH=$1
TFS_USER=$2
TFS_TOKEN=$3

JENKINS_TOKEN="11843f2e9da9e2dfa8c5559c1a259e5b11"
JENKINS_USER="admin"
JENKINS_PASS="admin"
JENKINS_URL="http://192.168.161.240:8320"
BASE_URL="http://192.168.160.166:8080/tfs/DMDL/"
REPO_URL="${BASE_URL}_git/GBGLIS"
HOOK_URL="${BASE_URL}_apis/hooks/subscriptions"
GBGLIS_DIR="/home/ironjab/gbgliscicd"

echo "UP START"

# [1] CHECK JOB
#############################################################################################
GBGLIS_JOB="$JENKINS_URL/job/GBGLIS/job/$BRANCH"
echo "Сhecking existence of the job: $GBGLIS_JOB"
JOB_STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" $GBGLIS_JOB/api/json --user $JENKINS_USER:$JENKINS_PASS)
if [[ $JOB_STATUS_CODE -eq 404 ]]; then
    echo "Job doesn't exist: $GBGLIS_JOB"
    exit 1
fi
echo "OK"
#############################################################################################

# [2] PREPARE DIR
#############################################################################################
echo "Preparing branch dir: $GBGLIS_DIR/$BRANCH"
git -c http.extraheader="AUTHORIZATION: Basic $(echo -n $TFS_USER:$TFS_TOKEN |base64 -w0)" clone -b $BRANCH --single-branch $REPO_URL "$GBGLIS_DIR/$BRANCH"
cd "$GBGLIS_DIR/$BRANCH"
ls -la
echo "OK"
#############################################################################################

# [3] TRIGGER JOB
#############################################################################################
# execute, works only with token
# curl -X POST http://192.168.161.240:8320/job/GBGLIS/job/develop_cicd_ironjab/build -u admin:11843f2e9da9e2dfa8c5559c1a259e5b11

#Wait until the build is up and running
# echo -n "Waiting"
# while true; do
#         STATUS_CODE=`curl --write-out %{http_code} --silent --output /dev/null  http://jenkins.minikube.io/job/$JOB/$BUILD_ID/api/json`
#         if [[ $STATUS_CODE -eq 404 ]]; then
#                 echo -n "."
#                 sleep 2
#         else
#                 break
#         fi
# done
# echo ""
#############################################################################################

# [4] CREATE SERVICE HOOK
#############################################################################################
service_hook_data() {
  cat <<EOF
{
  "publisherId": "tfs",
  "eventType": "git.push",
  "consumerId": "jenkins",
  "consumerActionId": "triggerGenericBuild",
  "publisherInputs": {
    "branch": "$BRANCH",
    "projectId": "327ebaa7-1ccd-48e3-90d5-96f8caa03664",
    "repository": "5fd70a75-7cc0-4596-9089-a84966188769"
  },
  "consumerInputs": {
    "buildName": "GBGLIS/$BRANCH",
    "serverBaseUrl": "$JENKINS_URL",
    "username": "$JENKINS_USER",
    "useTfsPlugin": "built-in",
    "password": "$JENKINS_PASS"
  },
}
EOF
}

# curl -s -H "Accept: application/json; api-version=1.0" -H "Content-Type:application/json" --data "$(service_hook_data)" -XPOST -u :$TFS_TOKEN $HOOK_URL
#############################################################################################

echo "UP DONE"