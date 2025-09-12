#!/bin/bash

source env.sh

cd $base_dir

kubectl apply -f ./yaml/coredns.yaml