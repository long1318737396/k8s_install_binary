#!/bin/bash
base_dir=`pwd`;cd $base_dir
source env.sh

install_cfssl() {
	echo "Installing cfssl..."
	if [ ! -f "kubernetes-v${k8s_version}-${ARCH}/cfssl*" ]; then
		echo "cfssl package not found, skipping cfssl installation"
		exit 1
	else
		/bin/cp kubernetes-v${k8s_version}-${ARCH}/cfssl* $bin_dir/
		/bin/cp kubernetes-v${k8s_version}-${ARCH}/cfssl-certinfo* $bin_dir/
		/bin/cp kubernetes-v${k8s_version}-${ARCH}/cfssljson* $bin_dir/
		chmod +x $bin_dir/cfssl*
	fi
}

install_cfssl