#!/bin/bash
base_dir=`pwd`
cd $base_dir
source env.sh
echo "==================================start system init======================================="

bash system_init.sh
echo "==================================end system init========================================="
if [ $runtime == "containerd" ];then
  echo "==================================start install containerd=============================="
  bash install_containerd.sh
elif [ $runtime == "docker" ];then
  echo "==================================start install docker=================================="
  bash install_docker.sh
elif [ $runtime == "crio" ];then
  echo "==================================start install crio===================================="
  bash install_crio.sh
else
  echo "runtime is not support"
  exit 1
fi

echo "==================================start install etcd======================================"
bash install_cfssl.sh
bash install_etcd.sh


echo "==================================start install k8s======================================="
bash install_k8s_apiserver.sh

echo "==================================start install k8s kcm==================================="
bash install_k8s_kcm.sh

echo "==================================start install k8s scheduler=============================="
bash install_k8s_scheduler.sh

echo "==================================start install k8s proxy=================================="
bash install_k8s_proxy.sh

echo "==================================start install k8s cni===================================="
bash install_k8s_cni.sh

