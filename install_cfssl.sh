#!/bin/bash
base_dir=`pwd`;cd $base_dir
source env.sh

install_cfssl() {
	echo "Installing cfssl..."
	if ! ls kubernetes-v${k8s_version}-${ARCH}/cfssl* >/dev/null 2>&1; then
		echo "cfssl package not found, skipping cfssl installation"
		exit 1
	else
		/bin/cp kubernetes-v${k8s_version}-${ARCH}/cfssl_* $bin_dir/cfssl
		/bin/cp kubernetes-v${k8s_version}-${ARCH}/cfssl-certinfo* $bin_dir/cfssl-certinfo
		/bin/cp kubernetes-v${k8s_version}-${ARCH}/cfssljson* $bin_dir/cfssljson
		chmod +x $bin_dir/cfssl*
	fi
}

install_cfssl
