#!/bin/bash
base_dir=`pwd`;cd $base_dir
source env.sh
install_docker() {
  echo "Installing Docker..."
  
  if [ ! -f "kubernetes-v${k8s_version}-${ARCH}/docker-${docker_version}.tgz" ]; then
    echo "Docker package not found, skipping Docker installation"
    exit 1
  fi

  tar -zxvf docker-${docker_version}.tgz -C kubernetes-v${k8s_version}-${ARCH}/
  /bin/cp kubernetes-v${k8s_version}-${ARCH}/docker/* ${bin_dir}/
  mkdir -p /usr/lib/systemd/system
  cat > /usr/lib/systemd/system/docker.service << EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
[Service]
Type=notify
ExecStart=${bin_dir}/dockerd
ExecReload=/bin/kill -s HUP \$MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
[Install]
WantedBy=multi-user.target
EOF

  mkdir -p /etc/docker
  tee /etc/docker/daemon.json <<-'EOF'
 {
    "exec-opts": ["native.cgroupdriver=systemd"],
    "insecure-registries" : ["registry.mydomain.com:5000"],
    "log-driver": "json-file",
    "data-root": "${docker_data_root}",
    "log-opts": {
        "max-size": "100m",
        "max-file": "10"
    },
    "bip": "169.254.123.1/24",
    "registry-mirrors": ["https://xbrfpgqk.mirror.aliyuncs.com","https://docker.gh-proxy.com"],
    "live-restore": true
}
EOF
  sed -i "s|\${docker_data_root}|$docker_data_root|g" /etc/docker/daemon.json
  systemctl enable docker --now
  if [ $? -ne 0 ];then
    echo "docker service start failed"
    exit 1
  fi

  mkdir -p /usr/lib/docker/cli-plugins
  if [ ! -f kubernetes-v${k8s_version}-${ARCH}/docker-buildx ];then
     echo "docker-buildx is not existed"
	 exit 1
  else
    /bin/cp kubernetes-v${k8s_version}-${ARCH}/buildx-v${docker_buildx_version=}.linux-${ARCH} /usr/lib/docker/cli-plugins/docker-buildx
    chmod +x /usr/lib/docker/cli-plugins/docker-buildx
  fi

  if [ -f "docker-compose-linux-${arch}" ]; then
    /bin/cp "docker-compose-linux-${arch}" "${bin_dir}/docker-compose"
    chmod +x "${bin_dir}/docker-compose"
  fi
  
  docker completion bash > /etc/profile.d/docker.sh

  if [ -f "kubernetes-v${k8s_version}-${ARCH}/cri-dockerd-${cri_docker_version}.${ARCH}.tgz" ];then
    tar -zxvf "kubernetes-v${k8s_version}-${ARCH}/cri-dockerd-${cri_docker_version}.${ARCH}.tgz -C kubernetes-v${k8s_version}-${ARCH}/"
    /bin/cp "kubernetes-v${k8s_version}-${ARCH}/cri-dockerd/cri-dockerd" "${bin_dir}/"
    cat > /etc/systemd/system/cri-docker.socket << EOF
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service

[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0666
SocketUser=root
SocketGroup=root

[Install]
WantedBy=sockets.target
EOF
    cat > /usr/lib/systemd/system/cri-docker.service << EOF
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket

[Service]
Type=notify
ExecStart=${bin_dir}/cri-dockerd --container-runtime-endpoint fd://
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

StartLimitBurst=3

StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
    systemctl start cri-docker --now
  else
    echo "cri-dockerd package not found, skipping cri-dockerd installation"
	exit 1
  fi
  
  echo "Docker installed."
}