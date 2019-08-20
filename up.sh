#!/bin/bash

BRANCH=$1

echo "up branch: ${BRANCH}"

cd /home/ironjab/gbgliscicd
git clone -b ${BRANCH} --single-branch http://192.168.160.166:8080/tfs/DMDL/_git/GBGLIS ${BRANCH}