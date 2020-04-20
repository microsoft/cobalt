#!/usr/bin/env bash
set -euo pipefail

# This script orchestrates the following actions, ultimately resulting in
# an Elasticsearch cluster being provisioned through ECE.
# 
# Steps:
#   - Verify that `jq` is installed
#   - Invoke a Create Deployment API request. This is an asynchronous operation.
#   - Poll deployment API until the cluster is healthy, or a timeout is exceeded.
#   - Query the Elasticsearch instance to retrieve its endpoint.
#
# Because this script is executed within the context of a Terraform local exec provisioner
# (docs: https://www.terraform.io/docs/provisioners/local-exec.html) it is important to
# note the following:
#   - All output to stdout is captured as the "response" of the command, and it is assumed
#     to be in the form of a map<string, string>.
#   - In order to provide context that is readable from terraform, all "logging" output
#     is done to stderr.
#
#

# Check if `jq` is installed. If not, fail fast.
command -v jq >/dev/null 2>&1 || { echo >&2 "jq is not installed. Please re-run after installing"; exit 1; }

: "${AUTH_TYPE?Required environment variable AUTH_TYPE is not set}"
: "${AUTH_TOKEN?Required environment variable AUTH_TOKEN is not set}"
: "${CLOUD?Required environment variable CLOUD is not set}"
: "${CLOUD_REGION?Required environment variable CLOUD_REGION is not set}"
: "${COORDINATOR_URL?Required environment variable COORDINATOR_URL is not set}"
: "${DEPLOYMENT_NAME?Required environment variable DEPLOYMENT_NAME is not set}"
: "${DEPLOYMENT_TEMPLATE_ID?Required environment variable DEPLOYMENT_TEMPLATE_ID is not set}"
: "${DEPLOYMENT_CONFIGURATION_ID?Required environment variable DEPLOYMENT_CONFIGURATION_ID is not set}"
: "${ES_NODE_MEMORY?Required environment variable ES_NODE_MEMORY is not set}"
: "${ES_ZONE_COUNT?Required environment variable ES_ZONE_COUNT is not set}"
: "${ES_NODES_PER_ZONE?Required environment variable ES_NODES_PER_ZONE is not set}"
: "${ES_VERSION?Required environment variable ES_VERSION is not set}"
: "${ES_NODE_DATA?Required environment variable ES_NODE_DATA is not set}"
: "${ES_NODE_INGEST?Required environment variable ES_NODE_INGEST is not set}"
: "${ES_NODE_MASTER?Required environment variable ES_NODE_MASTER is not set}"
: "${ES_NODE_ML?Required environment variable ES_NODE_ML is not set}"

# Invokes an ES API to create an ELK stack deployment
function createDeployment() {
    CREATE_RESPONSE=$(
        curl -s -XPOST "$COORDINATOR_URL/api/v1/deployments?validate_only=false" \
            -H "Authorization: $AUTH_TYPE $AUTH_TOKEN"                           \
            -H "Content-Type: application/json" --data-binary @- << EOF
            {
              "name": "$DEPLOYMENT_NAME",
              "resources": {
                "elasticsearch": [
                  {
                    "region": "$CLOUD-$CLOUD_REGION",
                    "ref_id": "main-elasticsearch",
                    "plan": {
                      "deployment_template": {
                        "id": "$DEPLOYMENT_TEMPLATE_ID"
                      },
                      "cluster_topology": [
                        {
                          "instance_configuration_id": "$DEPLOYMENT_CONFIGURATION_ID",
                          "node_type": {
                            "data":   ${ES_NODE_DATA},
                            "ingest": ${ES_NODE_INGEST},
                            "master": ${ES_NODE_MASTER},
                            "ml":     ${ES_NODE_ML}
                          },
                          "size": {
                            "resource": "memory",
                            "value": ${ES_NODE_MEMORY}
                          },
                          "zone_count":          ${ES_ZONE_COUNT}
                        }
                      ],
                      "elasticsearch": {
                        "version": "$ES_VERSION"
                      }
                    }
                  }
                ],
                "kibana": [],
                "apm": []
              }
            }
EOF
    )
  
    DEPLOYMENT_ID=$(echo "$CREATE_RESPONSE" | jq -r '.id')

    if [ $DEPLOYMENT_ID == "null" ]; then
      1>&2 echo "No deployment ID found in in create deployment response"
      1>&2 echo "$CREATE_RESPONSE"
      exit 1
    fi

    # pull all of the information out and then reconstruct into a single JSON response
    DEPLOYMENT_ID_JS=$(echo "$CREATE_RESPONSE" | jq -r '{deployment_id: .id}')
    CLUSTER_ID=$(echo "$CREATE_RESPONSE" | jq -r '.resources | {cluster_id: map(select(.kind == "elasticsearch"))[0].id}')
    CLUSTER_USERNAME=$(echo "$CREATE_RESPONSE" | jq -r '.resources | {cluster_username: map(select(.kind == "elasticsearch"))[0].credentials.username}')
    CLUSTER_PASSWORD=$(echo "$CREATE_RESPONSE" | jq -r '.resources | {cluster_password: map(select(.kind == "elasticsearch"))[0].credentials.password}')

    # this command merges all of the JSON documents constructed above
    echo \
        "$DEPLOYMENT_ID_JS"    \
        "$CLUSTER_ID"       \
        "$CLUSTER_USERNAME" \
        "$CLUSTER_PASSWORD" \
        | jq -s add
}

# Returns 'true' if the deployment is in a healthy state, 'false' otherwise
# This function takes a single argument, which is the deployment ID
function isDeploymentHealthy() {
    ES_API_RESPONSE=$(
        curl -s -XGET "$COORDINATOR_URL/api/v1/deployments/$1" \
            -H "Authorization: $AUTH_TYPE $AUTH_TOKEN"
    )
    DEPLOYMENT_HEALTH=$(echo "$ES_API_RESPONSE" | jq -r '.healthy')
    echo "$DEPLOYMENT_HEALTH"
}

# Loops until the ELK stack deployment is healthy
# This function takes a single argument, which is the deployment ID
function waitForHealthyDeployment() {
    1>&2 echo "Waiting for deployment $1 status to be HEALTHY"

    # the API will immediately return "healthy" for some unknown reason, so its
    # best to delay a little bit before checking!
    sleep 10

    until [ "$(isDeploymentHealthy "$1")" == "true" ]
    do
        1>&2 echo "Deployment not yet HEALTHY..."
        sleep 5
    done
    1>&2 echo "Deployment is HEALTHY"
}

# This function looks up the endpoint of an elasticsearch cluster
# This function takes a single argument, which is the elasticsearch ID
function lookupElasticsearchEndpoint() {
    ES_API_RESPONSE=$(
        curl -s -XGET "$COORDINATOR_URL/api/v1/deployments/$1" \
            -H "Authorization: $AUTH_TYPE $AUTH_TOKEN"
    )
    ES_INFO=$(echo "$ES_API_RESPONSE" | jq -r '.resources.elasticsearch[0].info')
    1>&2 echo "$ES_INFO"
    ENDPOINT_DOMAIN=$(echo "$ES_INFO" | jq -r '.metadata.endpoint')
    ENDPOINT_PORT=$(echo "$ES_INFO" | jq -r '.metadata.ports.https')
    echo "https://$ENDPOINT_DOMAIN:$ENDPOINT_PORT"
}


# Invoke the call to create a deployment
DEPLOYMENT_META=$(createDeployment)
1>&2 echo "Deployment submitted"
1>&2 echo "$DEPLOYMENT_META"
DEPLOYMENT_ID=$(echo "$DEPLOYMENT_META" | jq -r '.deployment_id')

# Makes function available to subprocess. Needed to use with `timeout` command
#   https://stackoverflow.com/a/31311722
export -f                    \
    waitForHealthyDeployment \
    isDeploymentHealthy

# Wait for the deployment to be healthy, with a timeout
timeout 8m bash -c 'waitForHealthyDeployment "'"$DEPLOYMENT_ID"'"'

ES_ENDPOINT=$(lookupElasticsearchEndpoint "$DEPLOYMENT_ID")
1>&2 echo "Elasticsearch endpoint: $ES_ENDPOINT"

# add endpoint to the properties collected so far and echo to stdout
echo "$DEPLOYMENT_META" | jq --arg ENDPOINT "$ES_ENDPOINT" '. + {cluster_endpoint: $ENDPOINT}'
