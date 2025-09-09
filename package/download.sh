#!/bin/bash
set -x

# 全局变量定义
arch=`arch`
if [ "$arch" == "x86_64" ];then
  ARCH=amd64
elif [ "$arch" == "aarch64" ];then
  ARCH=arm64
else
  echo "this arch is not unsupport"
  exit 1
fi

#-----------变量配置--------------
runtime="containerd"
base_url=https://ghfast.top
#https://github.com/cloudflare/cfssl/releases
cfssl_version=1.6.5
#https://github.com/cri-o/cri-o/releases#downloads
crio_version=1.33.4
cri_docker_version=0.3.20
#https://github.com/kubernetes-sigs/cri-tools/releases
crictl_version=v1.33.0
#https://github.com/projectcalico/calico/releases
calico_version=v3.30.0
#https://github.com/cilium/cilium/releases
cilium_version=v1.17.4
#https://github.com/cilium/cilium-cli/releases
cilium_cli_version=v0.18.3
#https://github.com/docker/compose/releases
docker_compose_version=v2.36.0
#https://mirrors.ustc.edu.cn/docker-ce/linux/static/stable/x86_64/
docker_version=28.4.0
#https://github.com/docker/buildx/releases
docker_buildx_version="v0.23.0"
#https://github.com/gojue/ecapture/releases
ecapture_version=v1.0.2
#https://github.com/etcd-io/etcd/releases
etcd_version=v3.6.0
#https://get.helm.sh/helm-v3.16.3-linux-amd64.tar.gz
#https://github.com/helm/helm/releases
helm_version=3.17.3
#https://github.com/cilium/hubble/releases
hubble_version=v1.17.3
#https://github.com/kubernetes/kubernetes/releases
k8s_version=1.33.4
#kubernetes_server_version=1.29.2
#https://github.com/kubernetes-sigs/gateway-api/releases/
gateway_api_version=v1.3.0
#https://github.com/containerd/nerdctl/releases
nerdctl_full_version=2.1.4
#https://github.com/mozillazg/ptcpdump/releases
ptcpdump_version=0.33.2
#https://github.com/lework/skopeo-binary/releases
skopeo_version=v1.18.0
#https://github.com/vmware-tanzu/velero/releases
velero_version=v1.16.0

setup_download_urls() {
  echo "Setting up download URLs..."
  calico_url="https://github.com/projectcalico/calico/releases/download/${calico_version}/calicoctl-linux-${ARCH}"
  cfssl_certinfo="https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssl-certinfo_${cfssl_version}_linux_${ARCH}"
  cfssl_url="https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssl_${cfssl_version}_linux_${ARCH}"
  cfssljson_url="https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssljson_${cfssl_version}_linux_${ARCH}"
  cilium_url="https://github.com/cilium/cilium-cli/releases/download/${cilium_cli_version}/cilium-linux-${ARCH}.tar.gz"
  crio_url="https://storage.googleapis.com/cri-o/artifacts/cri-o.${ARCH}.v${crio_version}.tar.gz"
  cri_docker_url="https://github.com/Mirantis/cri-dockerd/releases/download/v${cri_docker_version}/cri-dockerd-${cri_docker_version}.${ARCH}.tgz"
  crictl_url="https://github.com/kubernetes-sigs/cri-tools/releases/download/${crictl_version}/crictl-${crictl_version}-linux-$ARCH.tar.gz"
  docker_buildx_url="https://github.com/docker/buildx/releases/download/${docker_buildx_version}/buildx-${docker_buildx_version}.linux-${ARCH}"
  docker_compose_url="https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-linux-${arch}"
  docker_url="https://download.docker.com/linux/static/stable/${arch}/docker-${docker_version}.tgz"
  ecapture_url="https://github.com/gojue/ecapture/releases/download/${ecapture_version}/ecapture-${ecapture_version}-linux-${ARCH}.tar.gz"
  etcd_url="https://github.com/etcd-io/etcd/releases/download/${etcd_version}/etcd-${etcd_version}-linux-${ARCH}.tar.gz"
  helm_url="https://get.helm.sh/helm-v${helm_version}-linux-${ARCH}.tar.gz"
  hubble_url="https://github.com/cilium/hubble/releases/download/${hubble_version}/hubble-linux-${ARCH}.tar.gz"
  kubernetes_server_url="https://dl.k8s.io/release/v${k8s_version}/kubernetes-server-linux-${ARCH}.tar.gz"
  nerdctl_full_url="https://github.com/containerd/nerdctl/releases/download/v${nerdctl_full_version}/nerdctl-full-${nerdctl_full_version}-linux-$ARCH.tar.gz"
  pcpdump_url="https://github.com/mozillazg/ptcpdump/releases/download/v${ptcpdump_version}/ptcpdump_${ptcpdump_version}_linux_${ARCH}.tar.gz"
  skopeo_url="https://github.com/lework/skopeo-binary/releases/download/${skopeo_version}/skopeo-linux-${ARCH}"
  velero_url="https://github.com/vmware-tanzu/velero/releases/download/${velero_version}/velero-${velero_version}-linux-${ARCH}.tar.gz"
  echo "Download URLs setup completed."
}



# 下载所需软件包
download_packages() {
  echo "Downloading packages..."
  
  # 基础包列表（所有运行时都需要）
  packages=(
    "$calico_url"
    "$cfssl_certinfo"
    "$cfssl_url"
    "$cfssljson_url"
    "$cilium_url"
    "$cri_docker_url"
    "$crio_url"
    "$crictl_url"
    "$docker_buildx_url"
    "$docker_compose_url"
    "$docker_url"
    "$ecapture_url"
    "$etcd_url"
    "$helm_url"
    "$hubble_url"
    "$nerdctl_full_url"
    "$pcpdump_url"
	"$skopeo_url"
	"$velero_url"
  )

    mkdir kubernetes-v${k8s_version}-${ARCH}

    for package_url in "${packages[@]}"; do
      filename=$(basename "$package_url")
      if [ ! -f "$filename" ];then
        echo "Downloading $filename..."
        wget -4 -O kubernetes-v${k8s_version}-${ARCH}/"$filename" "$package_url"
        echo "Downloaded $filename"
      else
        echo "$filename is existed"
      fi
    done
  echo "Package downloads completed."
}



setup_download_urls
download_packages
tar -czvf kubernetes-v${k8s_version}-${ARCH}.tar.gz kubernetes-v${k8s_version}-${ARCH}