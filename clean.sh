#!/usr/bin/env bash
source lib/util/util.sh
source lib.sh
# 获取参数
all=${1}
# 检查本地仓库的容器是否在运行
localRegistryStarted=`runningDockerContainer docker-registry`

# 删除所有容器，除了本地仓库容器之外
if [ -z "$localRegistryStarted" ] ; then   
    docker rm -f $(docker ps -aq)
else
    echo "localRegistryStarted=$localRegistryStarted"
    killContainers=`docker ps -aq | sed -e "s/${localRegistryStarted}/ /"`
    echo "killContainers=$killContainers"
    docker rm -f ${killContainers}
fi

#TODO [ "${DOCKER_MACHINE_NAME}" == "orderer" ]  && EXECUTE_BY_ORDERER=1 runCLIWithComposerOverrides down || runCLIWithComposerOverrides down
# 删除开发环境的容器镜像
docker volume prune -f
docker rmi -f $(docker images -q -f "reference=dev-*")

# 在比较旧的桌面系统上运行docker，需要使用docker-machine来管理，通过DOCKER_HOST环境变量来区分
if [ -z "$DOCKER_HOST" ] ; then
    docker-compose -f docker-compose-clean.yaml run --rm cli.clean rm -rf crypto-config/*
    [ "$all" == "all" ] && docker-compose -f docker-compose-clean.yaml run --rm cli.clean rm -rf data/*
else   
    docker-machine ssh ${DOCKER_MACHINE_NAME} sudo rm -rf crypto-config
    [ "$all" == "all" ] && docker-machine ssh ${DOCKER_MACHINE_NAME} sudo rm -rf data/
fi

#docker rmi -f $(docker images -q -f "reference=shiqinfeng1/fabric-starter-client")
#docker network rm `(docker network ls -q)`
