#!/bin/bash

BRANCH=$1
USERNAME=$2
PASSWORD=$3


echo "up branch: ${BRANCH}"
echo $USERNAME
echo $PASSWORD

cd /home/ironjab/gbgliscicd
git clone -b ${BRANCH} --single-branch http://${USERNAME}:${PASSWORD}@192.168.160.166:8080/tfs/DMDL/_git/GBGLIS ${BRANCH}