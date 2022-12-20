#!/bin/sh
usage() {
  echo "使用方法: $0 FILE_NAME_DOCKER.tgz"
  echo "        $0 docker-20.10.17.tgz"
  echo "获取dokcer包地址 docker binary from: https://download.docker.com/linux/static/stable/x86_64/"
  echo "或者直接下载: wget https://download.docker.com/linux/static/stable/x86_64/docker-20.10.17.tgz"
  echo ""
}

DOCKERDIR=/usr/bin/
DOCKERBIN=docker
SERVICENAME=docker

IPFLG=true
DOCKERIP=""
DOCKERIPPOOL=""
INPUTFLG=true

checkIp() {
  local_ip=$(ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:")
  array=($(echo $local_ip | tr '\n' ' '))
  if [ $1 ]; then
    for var in ${array[@]}; do
      if [[ $var =~ "$1" ]]; then
        INPUTFLG=false
        break
      fi
    done
  else
    for var in ${array[@]}; do
      if [[ $var =~ "172." ]]; then
        IPFLG=false
        break
      fi
    done
  fi
}

creatDaemon() {
  #创建配置文件
  sudo mkdir -p /etc/docker
  cat >/etc/docker/daemon.json <<EOF
{
  "bip": "${DOCKERIP}/24",
  "default-address-pools": [
    {
      "base": "${DOCKERIPPOOL}/16",
      "size": 24
    }
  ]
}
EOF
}

if [ $# -ne 1 ]; then
  usage
  exit 1
else
  FILETARGZ="$1"
fi

if [ ! -f ${FILETARGZ} ]; then

  usage
  echo Error $1 文件不存在
  exit 1
fi

checkIp

if [ $IPFLG == true ]; then
  insertDocker
else
  echo "监测到你的网卡与docker网卡冲突 请手动配置docker网卡 按照下面提示安装"
  echo "输入docker网卡ip"
  read docip
  if [ ! $docip ]; then
    echo "Error 不可输入空的IP "
    exit 1
  fi
  checkIp $docip
  if [ ${INPUTFLG} == true ]; then
    DOCKERIP=$docip
    echo "请输入docker网络池的初始IP "
    read poolip
    if [ ! $poolip ]; then
      echo "Error 不可输入空的IP "
      exit 1
    fi
    DOCKERIPPOOL=$poolip
    echo "docker ip is $DOCKERIP  docker address pools $DOCKERIPPOOL "
    creatDaemon
    insertDocker
  else
    echo "Error IP 冲突"
    exit 1
  fi
fi

insertDocker() {
  ##解压
  echo "##tar : tar zxvf ${FILETARGZ}"
  tar zxvf ${FILETARGZ}
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
  docker version

  ##清理安装残留
  rm -rf docker
}
