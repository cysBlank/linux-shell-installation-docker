#!/bin/bash

SYSTEMDDIR=/usr/lib/systemd/system
#SYSTEMDDIR=/opt
DOCKERDIR=/usr/bin
#DOCKERDIR=/tmp
echo "start uninstalling  docker"
echo "======================================="
# 停止docker服务
sudo systemctl stop docker

echo '删除docker.service...'
rm -rf  ${SYSTEMDDIR}/docker.service
rm -rf  ${SYSTEMDDIR}/docker.socket

echo '删除docker文件...'
rm -rf ${DOCKERDIR}/docker*
rm -rf ${DOCKERDIR}/containerd-shim*
rm -rf ${DOCKERDIR}/containerd
rm -rf ${DOCKERDIR}/ctr
rm -rf ${DOCKERDIR}/runc
rm -rf ${DOCKERDIR}/docker-compose

echo '是否删除镜像/容器/docker配置 [y/n]'
read flg

if [ ${flg^^} == Y ] 
then
   echo '删除docker配置'
  rm -rf /etc/docker/
  
  echo '删除docker容器和镜像'
  rm -rf /var/lib/docker/ 

else
 echo "保留配置"
fi

echo '重新加载配置文件'
systemctl daemon-reload

echo '卸载成功...'  

