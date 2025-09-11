#!/bin/bash

source env.sh

cd $base_dir

cat ./kube-flannel.yaml |envsubst | tee /tmp/kube-flannel.yaml

kubectl apply -f /tmp/kube-flannel.yaml