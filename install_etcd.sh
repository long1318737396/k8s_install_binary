#!/bin/bash
base_dir=`pwd`;cd $base_dir
source env.sh

install_etcd() {
	echo "Installing etcd..."
	if [ ! -f "kubernetes-v${k8s_version}-${ARCH}/etcd-${etcd_version}-linux-${ARCH}.tar.gz" ]; then
		echo "etcd package not found, skipping etcd installation"
		exit 1
	else
		tar -zxvf "kubernetes-v${k8s_version}-${ARCH}/etcd-${etcd_version}-linux-${ARCH}.tar.gz" -C kubernetes-v${k8s_version}-${ARCH}/
		/bin/cp kubernetes-v${k8s_version}-${ARCH}/etcd-${etcd_version}-linux-${ARCH}/etcd $bin_dir/
		/bin/cp kubernetes-v${k8s_}
	fi
}	