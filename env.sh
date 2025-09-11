#!/bin/bash
base_dir=`pwd`
# 全局变量定义
arch=`arch`
if [ "$arch" == "x86_64" ];then
  ARCH=amd64
elif [ "$arch" == "aarch64" ];then
  ARCH=arm64
else
  echo "this arch is not unsupport"
  #exit 1
fi



#-----------变量配置--------------
runtime="containerd"
bin_dir=/usr/local/bin
export docker_data_root=/var/lib/docker
export pod_network_cidr=10.244.0.0/16
service_cidr=10.96.0.0/12

calico_version=v3.30.0
cfssl_version=1.6.5
cilium_cli_version=v0.18.3
cilium_version=v1.17.4
cri_docker_version=0.3.20
crio_version=1.33.4
crictl_version=v1.33.0
docker_buildx_version="v0.23.0"
docker_compose_version=v2.36.0
docker_version=28.4.0
ecapture_version=v1.0.2
etcd_version=v3.6.0
gateway_api_version=v1.3.0
helm_version=3.17.3
hubble_version=v1.17.3
k8s_version=1.33.4
nerdctl_full_version=2.1.4
ptcpdump_version=0.33.2
skopeo_version=v1.18.0
velero_version=v1.16.0

base_url=https://ghfast.top


DEFAULT_INTERFACE=$(ip route show default | awk '/default/ {print $5}')
IP_ADDRESS=$(ip addr show "$DEFAULT_INTERFACE" | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
HOSTNAME="k8s-$(echo "$IP_ADDRESS" | tr '.' '-')"