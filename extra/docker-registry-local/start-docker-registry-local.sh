#!/usr/bin/env bash

: ${FABRIC_VERSION:="latest"}
: ${FABRIC_STARTER_VERSION:="latest"}
: ${JAVA_RUNTIME_VERSION:="latest"}

: ${DOCKER_REGISTRY_LOCAL:=localhost:5000}
echo "Using local docker registry address: $DOCKER_REGISTRY_LOCAL"

unset DOCKER_HOST DOCKER_MACHINE_NAME DOCKER_CERT_PATH DOCKER_HOST DOCKER_TLS_VERIFY

BASEDIR=$(dirname "$0")

docker-compose -f ${BASEDIR}/docker-compose-local-docker.yaml up -d

dockerImages=(\
    "registry.cn-shanghai.aliyuncs.com/hyperledger-bin/fabric-baseimage:amd64-0.4.15" \
    "registry.cn-shanghai.aliyuncs.com/hyperledger-bin/fabric-baseimage:latest" \
    "registry.cn-shanghai.aliyuncs.com/hyperledger-bin/fabric-baseos" \
    "registry.cn-shanghai.aliyuncs.com/hyperledger-bin/fabric-javaenv:${FABRIC_VERSION}" \
    "registry.cn-shanghai.aliyuncs.com/hyperledger-bin/fabric-ccenv:${FABRIC_VERSION}" \
    "registry.cn-shanghai.aliyuncs.com/hyperledger-bin/fabric-orderer:${FABRIC_VERSION}" \
    "registry.cn-shanghai.aliyuncs.com/hyperledger-bin/fabric-peer:${FABRIC_VERSION}" \
    "registry.cn-shanghai.aliyuncs.com/hyperledger-bin/fabric-ca:${FABRIC_VERSION}" \
    "registry.cn-shanghai.aliyuncs.com/hyperledger-bin/fabric-couchdb" \
    "registry.cn-shanghai.aliyuncs.com/shiqinfeng1/nginx" \
    "registry.cn-shanghai.aliyuncs.com/shiqinfeng1/fabric-starter-rest:${FABRIC_STARTER_VERSION:-latest}" \
    "registry.cn-shanghai.aliyuncs.com/shiqinfeng1/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}" \
    "apolubelov/fabric-scalaenv:${JAVA_RUNTIME_VERSION:-latest}"
    )


function checkError() {
    local errCode=$?
    [ "$errCode" -ne 0 ] && echo "Return Code $errCode" && exit 1
}

for image in "${dockerImages[@]}"
do
    docker pull ${image}
    checkError
    docker tag ${image} "${DOCKER_REGISTRY_LOCAL}/${image}"
    checkError
    docker push ${DOCKER_REGISTRY_LOCAL}/${image}
    checkError
done
