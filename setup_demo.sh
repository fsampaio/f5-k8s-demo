#!/bin/bash

##
## Use this script to automatically: 
## 1- Deploy F5 CC 
## 2- Deploy our frontend-app using BIG-IP 
## 3- Deploy our ASPs
## 4- Replace kube-proxy
## 5- Deploy our backend application using ASP
##

##
## Create F5 kubernetes partition
##
curl -k -u admin:admin -H "Content-Type: application/json" -X POST -d '{"name":"kubernetes", "fullPath": "/kubernetes", "subPath": "/"}' https://10.1.1.8/mgmt/tm/sys/folder |python -m json.tool

##
## Create BIG-IP kubectl secret
##

printf "##############################################\n"
printf "Create BIG-IP secret\n"
printf "##############################################\n\n\n"

kubectl create secret generic bigip-login --namespace kube-system --from-literal=username=admin --from-literal=password=admin

##
## Deploy F5 BIG-IP CC
##

printf "##############################################\n"
printf "Deploy BIG-IP CC\n"
printf "##############################################\n\n\n"

kubectl create -f f5-cc-deployment.yaml

##
## Deploy our frontend application and associate the relevant service/configmap to setup the BIG-IP
## 

printf "##############################################\n"
printf "Deploy FRONTEND APP\n"
printf "##############################################\n\n\n"

kubectl create -f my-frontend-deployment.yaml

kubectl create -f my-frontend-configmap.yaml

kubectl create -f my-frontend-service.yaml

##
## Deploy ASP and the relevant configmap
##

printf "##############################################\n"
printf "Deploy ASP\n"
printf "##############################################\n\n\n"

kubectl create -f f5-asp-configmap.yaml

kubectl create -f f5-asp-daemonset.yaml

##
## Replace kube-proxy with our kube-proxy
##
printf "##############################################\n"
printf "Deploy F5 KUBE PROXY\n"
printf "##############################################\n\n\n"


kubectl delete -f kube-proxy-origin.yaml

kubectl create -f f5-kube-proxy-ds.yaml

##
## Deploy backend application leveraging ASP
##

printf "##############################################\n"
printf "Deploy BACKEND\n"
printf "##############################################\n\n\n"

kubectl create -f my-backend-deployment.yaml

kubectl create -f my-backend-service.yaml

printf "##############################################\n"
printf "Connect to Frontend APP with http://10.1.10.80\n"
printf "##############################################\n\n\n"

printf "##############################################\n"
printf "Using command: kubectl get pods --all-namespaces to check containers status\n"
printf "Make sure that everything is up and running\n"
printf "Wait for all containers related to the demo to be in running mode\n"
printf "##############################################\n\n\n"
kubectl get pods --all-namespaces
