#!/bin/bash

BRANCH=$1
USERNAME=$2
PAT=$3


echo "up branch: ${BRANCH}"
echo "username: ${USERNAME}"
echo "password: ${PAT}"

cd /home/ironjab/gbgliscicd
git -c http.extraheader="AUTHORIZATION: Basic $(echo -n $USERNAME:$PAT |base64 -w0)" clone -b develop_cicd_ironjab --single-branch http://192.168.160.166:8080/tfs/DMDL/_git/GBGLIS develop_cicd_ironjab