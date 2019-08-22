#!/bin/bash

set -e

BRANCH=$1
DOMAIN=$2
TFS_USER=$3
TFS_TOKEN=$4

GBGLIS_DIR="/home/ironjab/gbglis/$BRANCH"
NGINX_DIR="/home/ironjab/nginx/conf.d"
NGINX_CONTAINER_NAME="global-nginx"
BASE_URL="http://192.168.160.166:8080/tfs/DMDL/"
HOOK_URL="${BASE_URL}_apis/hooks/subscriptions"

echo "[0] DOWN START"

# [1] STOP/REMOVE APP
#############################################################################################
echo "[1] Stopping app for: $BRANCH"

if [ -d $GBGLIS_DIR ]; then
    cd $GBGLIS_DIR
    echo "[1] running docker-compose down, pwd: $PWD"
    [ -f $GBGLIS_DIR/docker-compose.* ] && docker-compose down
    echo "[1] Removing app dir: $GBGLIS_DIR"
    rm -rf $GBGLIS_DIR
else
    echo "[1] Skipped. Dir: $GBGLIS_DIR does not exists"
fi

echo "[1] OK"
#############################################################################################

# [2] REMOVE NGINX CONFS
#############################################################################################
echo "[2] Removing nginx confs for: $BRANCH"
echo "[2] Removing WEB config: $NGINX_DIR/$BRANCH.$DOMAIN.conf"
[ -f $NGINX_DIR/$BRANCH.$DOMAIN.conf ] && rm $NGINX_DIR/$BRANCH.$DOMAIN.conf
echo "[2] Removing API config: $NGINX_DIR/$BRANCH-api.$DOMAIN.conf"
[ -f $NGINX_DIR/$BRANCH-api.$DOMAIN.conf ] && rm $NGINX_DIR/$BRANCH-api.$DOMAIN.conf
echo "[2] Removing IDENTITY config: $NGINX_DIR/$BRANCH-identity.$DOMAIN.conf"
[ -f $NGINX_DIR/$BRANCH-identity.$DOMAIN.conf ] && rm $NGINX_DIR/$BRANCH-identity.$DOMAIN.conf
echo "[2] Restarting nginx"
docker kill -s HUP $NGINX_CONTAINER_NAME
echo "[2] OK"
#############################################################################################

# [3] REMOVE TFS SERVICE HOOKS
#############################################################################################
echo "[3] Removing TFS service hooks for: $BRANCH"

apt update -qq && apt install -y -qq jq

remove_hook() {
    HOOK_ID=$1
    echo "Removing hook: $HOOK_ID"
    STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" -XDELETE -H "Accept: api-version=1.0" -u :$TFS_TOKEN $HOOK_URL/$HOOK_ID)
    if [[ $STATUS_CODE -eq 204 ]]; then
            echo "Hook '$HOOK_ID' successfully removed"
    else
            echo "Hook '$HOOK_ID' didn't remove, status code: $STATUS_CODE"
            exit 1
    fi
}

# export -f remove_hook
# curl -s -H "Accept: application/json; api-version=1.0" -H "Content-Type:application/json" -XGET -u :$TFS_TOKEN $HOOK_URL | jq -c --arg BRANCH "$BRANCH" '.value[] | select(.publisherInputs.branch | contains($BRANCH)) | .id' |xargs -n1 bash -c 'remove_hook "$@"' _
HOOK_IDS=$(curl -s -H "Accept: application/json; api-version=1.0" -H "Content-Type:application/json" -XGET -u :$TFS_TOKEN $HOOK_URL | jq -c --arg BRANCH "$BRANCH" '[ .value[] | select(.publisherInputs.branch | contains($BRANCH)) | .id ]')
echo $HOOK_IDS

echo "[3] OK"
#############################################################################################

echo "[0] DOWN DONE"