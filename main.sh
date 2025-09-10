#!/bin/bash
base_dir=`pwd`;cd $base_dir
source env.sh
bash system_init.sh
if [ $runtime == "containerd" ];then ]
  bash install_containerd.sh
elif [ $runtime == "docker" ];then
  bash install_docker.sh
elif [ $runtime == "crio" ];then
  bash install_crio.sh
else
  echo "runtime is not support"
  exit 1
fi

bash inestall_etcd.sh

bash install_nginx.sh

bash install_k8s_apiserver.sh

bash install_k8s_kcm.sh

bash install_k8s_scheduler.sh

bash install_k8s_proxy.sh

bash install_k8s_cni.sh

