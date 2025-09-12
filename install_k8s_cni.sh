#!/bin/bash

source env.sh

cd $base_dir

tar -zxvf "kubernetes-v${k8s_version}-${ARCH}/helm-v${helm_version}-linux-${ARCH}.tar.gz" -C kubernetes-v${k8s_version}-${ARCH}
/bin/cp kubernetes-v${k8s_version}-${ARCH}/linux-${ARCH}/helm ${bin_dir}/helm
chmod +x ${bin_dir}/helm

cat ./yaml/kube-flannel.yaml |envsubst | tee /tmp/kube-flannel.yaml

kubectl apply -f /tmp/kube-flannel.yaml