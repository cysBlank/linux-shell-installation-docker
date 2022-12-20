#!/bin/sh
usage(){
  echo "使用方法: $0 FILE_NAME_DOCKER.tgz"
  echo "        $0 docker-20.10.17.tgz"
  echo "获取dokcer包地址 docker binary from: https://download.docker.com/linux/static/stable/x86_64/"
  echo "或者直接下载: wget https://download.docker.com/linux/static/stable/x86_64/docker-20.10.17.tgz"
  echo ""
}
#DOCKERDIR=/tmp
DOCKERDIR=/usr/bin
DOCKERBIN=docker
SERVICENAME=docker

if [ $# -ne 1 ]; then
  usage
  exit 1
else
  FILETARGZ="$1"
fi

if [ ! -f ${FILETARGZ} ]; then
  echo "Docker binary tgz files does not exist, please check it"
  echo "Get docker-ce binary from: https://download.docker.com/linux/static/stable/x86_64/"
  echo "eg: wget https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz"
  exit 1
fi
##解压
echo "##tar : tar zxvf ${FILETARGZ}"
tar zxvf  ${FILETARGZ}
echo

##拷贝
echo "##binary : ${DOCKERBIN} copy to ${DOCKERDIR}"
cp -p ${DOCKERBIN}/* ${DOCKERDIR} >/dev/null 2>&1
#which ${DOCKERBIN}

#echo "##systemd service: ${SERVICEFILE}"
echo "##docker.service: create docker systemd file  "
#注册service
sh REGDocker.sh 

## reload system
systemctl daemon-reload
echo "##Service status: ${SERVICENAME}"
systemctl status ${SERVICENAME}
echo "##Service restart: ${SERVICENAME}"
systemctl restart ${SERVICENAME}
echo "##Service status: ${SERVICENAME}"
systemctl status ${SERVICENAME}
echo "##Service enabled: ${SERVICENAME}"
systemctl enable ${SERVICENAME}

echo "## docker version"
docker  version

##清理安装残留
rm -rf docker
