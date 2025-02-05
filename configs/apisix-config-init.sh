#! /usr/bin/env sh
set -e
set -x

export APISIX_SERVICE_HOST=${APISIX_SERVICE_HOST:-apisix}
export APISIX_SERVICE_ADMIN_PORT=${APISIX_SERVICE_ADMIN_PORT:-9180}
export APISIX_SERVICE_ADMIN_SECRET=${APISIX_SERVICE_ADMIN_SECRET:-topsecret}
CURL_OPTS="--silent --show-error --fail"

# Delete

## routes
routes=$(curl $CURL_OPTS -X GET -H "X-API-KEY: ${APISIX_SERVICE_ADMIN_SECRET}" http://${APISIX_SERVICE_HOST}:${APISIX_SERVICE_ADMIN_PORT}/apisix/admin/routes | jq -r '.list[]|.value.id')

for route in $routes; do
  curl $CURL_OPTS -X DELETE -H "X-API-KEY: ${APISIX_SERVICE_ADMIN_SECRET}" http://${APISIX_SERVICE_HOST}:${APISIX_SERVICE_ADMIN_PORT}/apisix/admin/routes/$route
done

## services
services=$(curl $CURL_OPTS -X GET -H "X-API-KEY: ${APISIX_SERVICE_ADMIN_SECRET}" http://${APISIX_SERVICE_HOST}:${APISIX_SERVICE_ADMIN_PORT}/apisix/admin/services | jq -r '.list[]|.value.id')

for service in $services; do
  curl $CURL_OPTS -X DELETE -H "X-API-KEY: ${APISIX_SERVICE_ADMIN_SECRET}" http://${APISIX_SERVICE_HOST}:${APISIX_SERVICE_ADMIN_PORT}/apisix/admin/services/$service
done

# Create

## service

### Web1
curl $CURL_OPTS -X PUT -H "X-API-KEY: ${APISIX_SERVICE_ADMIN_SECRET}" http://${APISIX_SERVICE_HOST}:${APISIX_SERVICE_ADMIN_PORT}/apisix/admin/services/1 -d '
{
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "whoami:80": 1
        }
    }
}'


## routes

### Web1
curl $CURL_OPTS -X PUT -H "X-API-KEY: ${APISIX_SERVICE_ADMIN_SECRET}" http://${APISIX_SERVICE_HOST}:${APISIX_SERVICE_ADMIN_PORT}/apisix/admin/routes/11 -d '
{
    "uri": "/*",
    "service_id": "1",
    "methods": [
        "GET",
        "POST",
        "PUT",
        "DELETE"
    ],
    "plugins": {
        "opa": {
            "host": "http://opal_client:8181",
            "policy": "example",
            "ssl_verify": false
        }
    }
}'
