#!/bin/bash
base_dir=`pwd`;cd $base_dir
source env.sh
bash cfssl_install.sh
install_etcd() {
	echo "Installing etcd..."
	if [ ! -f "kubernetes-v${k8s_version}-${ARCH}/etcd-${etcd_version}-linux-${ARCH}.tar.gz" ]; then
		echo "etcd package not found, skipping etcd installation"
		exit 1
	else
		tar -zxvf "kubernetes-v${k8s_version}-${ARCH}/etcd-${etcd_version}-linux-${ARCH}.tar.gz" -C kubernetes-v${k8s_version}-${ARCH}/
		/bin/cp kubernetes-v${k8s_version}-${ARCH}/etcd-${etcd_version}-linux-${ARCH}/etcd* $bin_dir/
	fi
	mkdir /etc/etcd/ssl -p
	cd /etc/etcd/ssl
	cat > ca-config.json << EOF 
{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "876000h"
      }
    }
  }
}
EOF
  
  cat > etcd-ca-csr.json  << EOF 
{
  "CN": "etcd",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "etcd",
      "OU": "Etcd Security"
    }
  ],
  "ca": {
    "expiry": "876000h"
  }
}
EOF

  cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare /etc/etcd/ssl/etcd-ca
  
  cat > etcd-csr.json << EOF 
{
  "CN": "etcd",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "etcd",
      "OU": "Etcd Security"
    }
  ]
}
EOF

  cfssl gencert \
   -ca=/etc/etcd/ssl/etcd-ca.pem \
   -ca-key=/etc/etcd/ssl/etcd-ca-key.pem \
   -config=ca-config.json \
   -hostname=127.0.0.1,$IP_ADDRESS,localhost,$HOSTNAME \
   -profile=kubernetes \
   etcd-csr.json | cfssljson -bare /etc/etcd/ssl/etcd
  
  cat > /etc/etcd/etcd.config.yml << EOF 
name: "${HOSTNAME}"
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: https://${IP_ADDRESS}}:2380"
listen-client-urls: "https://${IP_ADDRESS}:2379,http://127.0.0.1:2379"
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: https://${IP_ADDRESS}:2380
advertise-client-urls: https://${IP_ADDRESS}:2379
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: "${HOSTNAME}=https://${IP_ADDRESS}:2380"
initial-cluster-token: 'etcd-k8s-cluster'
initial-cluster-state: 'new'
strict-reconfig-check: false
enable-v2: true
enable-pprof: true
proxy: 'off'
proxy-failure-wait: 5000
proxy-refresh-interval: 30000
proxy-dial-timeout: 1000
proxy-write-timeout: 5000
proxy-read-timeout: 0
client-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
peer-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  peer-client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
debug: false
log-package-levels:
log-outputs: [default]
force-new-cluster: false
EOF

  cat > /usr/lib/systemd/system/etcd.service << EOF

[Unit]
Description=Etcd Service
Documentation=https://coreos.com/etcd/docs/latest/
After=network.target

[Service]
Type=notify
ExecStart=${bin_dir}/etcd --config-file=/etc/etcd/etcd.config.yml
Restart=on-failure
RestartSec=10
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
Alias=etcd3.service

EOF

  mkdir /etc/kubernetes/pki/etcd
  ln -s /etc/etcd/ssl/* /etc/kubernetes/pki/etcd/
  systemctl daemon-reload
  systemctl enable --now etcd.service
  if [ $? -ne 0 ];then
    echo "etcd service start failed"
    exit 1
  fi
  export ETCDCTL_API=3
  etcdctl --endpoints="${IP_ADDRESS}:2379" --cacert=/etc/kubernetes/pki/etcd/etcd-ca.pem --cert=/etc/kubernetes/pki/etcd/etcd.pem --key=/etc/kubernetes/pki/etcd/etcd-key.pem  endpoint status --write-out=table
}	