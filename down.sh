#!/bin/bash

BRANCH=$1
DOMAIN=$2
TFS_USER=$3
TFS_TOKEN=$4

GBGLIS_DIR="/home/ironjab/gbglis/$BRANCH"
NGINX_DIR="/home/ironjab/nginx/conf.d"
NGINX_CONTAINER_NAME="global-nginx"
BASE_URL="http://192.168.160.166:8080/tfs/DMDL/"
HOOK_URL="${BASE_URL}_apis/hooks/subscriptions"

# 1 cd branch dir
# 2 docker-compose down
# 3 remove dir
# 4 remove service hook
#   4.1 list all hooks
#   4.2 search by .publisherInputs.branch
#   4.3 remove
# 5 remove nginx conf / restart

echo "[0] DOWN START"

# [1] STOP/REMOVE APP
#############################################################################################
# echo "[1] Stopping app for: $BRANCH"

# if [ -d $GBGLIS_DIR ]; then
#     cd $GBGLIS_DIR
#     echo "[1] running docker-compose down, pwd: $PWD"
#     docker-compose down
#     echo "[1] Removing app dir: $GBGLIS_DIR"
#     rm -rf $GBGLIS_DIR
# else
#     echo "[1] Skipped. Dir: $GBGLIS_DIR does not exists"
# fi

# echo "[1] OK"
#############################################################################################

# [2] REMOVE NGINX CONFS
#############################################################################################
# echo "[2] Removing nginx confs for: $BRANCH"
# echo "[2] Removing WEB config"
# [ -f $NGINX_DIR/$BRANCH.$DOMAIN.conf ] && rm $NGINX_DIR/$BRANCH.$DOMAIN.conf
# echo "[2] Removing API config"
# [ -f $NGINX_DIR/$BRANCH-api.$DOMAIN.conf ] && rm $NGINX_DIR/$BRANCH-api.$DOMAIN.conf
# echo "[2] Removing IDENTITY config"
# [ -f $NGINX_DIR/$BRANCH-identity.$DOMAIN.conf ] && rm $NGINX_DIR/$BRANCH-identity.$DOMAIN.conf
# echo "[2] Restarting nginx"
# docker kill -s HUP $NGINX_CONTAINER_NAME
# echo "[2] OK"
#############################################################################################

# [3] REMOVE TFS SERVICE HOOKS
#############################################################################################
echo "[3] Removing TFS service hooks for: $BRANCH"

apt update -qq && apt install -y -qq jq

asdf() {
    echo $1
}

echo $BRANCH
echo "curl -s -H \"Accept: application/json; api-version=1.0\" -H \"Content-Type:application/json\" -XGET -u :$TFS_TOKEN $HOOK_URL | jq -c '[ .value[] | select(.publisherInputs.branch | contains(\"$BRANCH\")) | .id ]'"

# export -f asdf
# curl -s -H "Accept: application/json; api-version=1.0" -H "Content-Type:application/json" -XGET -u :$TFS_TOKEN $HOOK_URL | jq -c '[ .value[] | select(.publisherInputs.branch | contains("$BRANCH")) | .id ]' |xargs -n1 bash -c 'asdf "$@"' _
curl -s -H "Accept: application/json; api-version=1.0" -H "Content-Type:application/json" -XGET -u :$TFS_TOKEN $HOOK_URL | jq -c '[ .value[] | select(.publisherInputs.branch | contains(\""$BRANCH"\")) | .id ]'
# echo "HOOKS: $HOOKS"


echo "[3] OK"
#############################################################################################

echo "[0] DOWN DONE"