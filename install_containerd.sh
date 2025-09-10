#!/bin/bash
base_dir=`pwd`;cd $base_dir
source env.sh
install_containerd() {
  echo "Installing containerd components..."
  
  if [ ! -f "kubernetes-v${k8s_version}-${ARCH}/nerdctl-full-${nerdctl_full_version}-linux-${ARCH}.tar.gz" ]; then
    echo "nerdctl package not found, skipping containerd installation"
    exit 1
  fi

  mkdir -p /usr/local/bin
  tar -zxvf "kubernetes-v${k8s_version}-${ARCH}/nerdctl-full-${nerdctl_full_version}-linux-${ARCH}.tar.gz" -C /usr/local/
  mkdir -p /etc/systemd/system/
  /bin/cp /usr/local/lib/systemd/system/*.service /etc/systemd/system/
  mkdir -p /opt/cni/bin
  /bin/cp /usr/local/libexec/cni/* /opt/cni/bin/

  systemctl enable buildkit containerd
  systemctl start buildkit containerd 
  if [ $? -ne 0 ];then
    echo "containerd service start failed"
    exit 1
  fi

  echo "source <(nerdctl completion bash)" /etc/profile.d/nerdctl.sh
  mkdir -p /etc/nerdctl/
  tee /etc/nerdctl/nerdctl.toml <<EOF
debug             = false
debug_full        = false
address           = "unix:///var/run/containerd/containerd.sock"
namespace         = "k8s.io"
snapshotter       = "overlayfs"
cni_path          = "/opt/cni/bin"
cni_netconfpath   = "/etc/cni/net.d"
cgroup_manager    = "systemd"
insecure_registry = true
hosts_dir         = ["/etc/containerd/certs.d"]
EOF

  mkdir -p /etc/containerd/
  containerd config default > /etc/containerd/config.toml
  sed -i "s#registry.k8s.io#registry.aliyuncs.com/google_containers#g" /etc/containerd/config.toml

  # 镜像加速配置
  mkdir /etc/containerd/certs.d/docker.io -pv
  cat > /etc/containerd/certs.d/docker.io/hosts.toml << EOF
server = "https://docker.io"
[host."https://jockerhub.com"]
  capabilities = ["pull", "resolve"]
EOF

  systemctl restart containerd 
  if [ $? -ne 0 ];then
    echo "containerd service restart failed"
    exit 1
  fi
  
  echo "Containerd components installed."
}

install_containerd