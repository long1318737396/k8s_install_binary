#!/bin/bash
source env.sh
cd $base_dir

kubectl apply -f ./yaml/ingress-nginx-controller.yaml
kubectl apply -f ./yaml/ingress-demo-app.yaml

kubectl apply -f ./yaml/metrics-server.yaml