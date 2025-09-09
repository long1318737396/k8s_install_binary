#!/bin/bash
base_dir=`pwd`;cd $base_dir
source env.sh
#-------安装crio相关组件---------
install_crio() {
  echo "Installing CRI-O..."
  
  if [ -f "kubernetes-v${k8s_version}-${ARCH}/cri-o.${ARCH}.v${crio_version}.tar.gz" ];then
    tar -zxvf "kubernetes-v${k8s_version}-${ARCH}/cri-o.${ARCH}.v${crio_version}.tar.gz -C kubernetes-v${k8s_version}-${ARCH}/"
    cd kubernetes-v${k8s_version}-${ARCH}/cri-o
    bash install
    systemctl daemon-reload
    systemctl enable --now crio
    if [ $? -ne 0 ];then
      echo "crio service start failed"
      exit 1
    fi
    cd $base_dir
  else
    echo "CRI-O package not found, skipping installation"
    exit 1
  fi
  
  echo "CRI-O installed."
}