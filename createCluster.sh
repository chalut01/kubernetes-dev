#!/bin/bash

# Create k8s cluster
kind create cluster --name istio-testing --config kind/kind.conf

kubectl cluster-info --context kind-istio-testing

# install calico
kubectl apply -f calico/calico-v3.23.yaml
kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true

# verify calico is Up
kubectl -n kube-system get pods | grep calico-node


# install istioctl on PC
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.13.4
export PATH=$PWD/bin:$PATH
istioctl version

# install istion to k8s
istioctl install --set profile=demo -y

# mark label default namespace to istio-injection=enabled
kubectl label namespace default istio-injection=enabled

# Deploy example application
kubectl apply -f Bookinfo/bookinfo.yaml
kubectl get services
kubectl get pods

# Deploy gateway
kubectl apply -f Bookinfo/bookinfo-gateway.yaml

# get service
kubectl get svc istio-ingressgateway -n istio-system


export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=127.0.0.1
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo "$GATEWAY_URL"
echo "http://$GATEWAY_URL/productpage"




