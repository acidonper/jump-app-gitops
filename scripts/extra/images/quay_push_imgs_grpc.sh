#!/bin/bash
##
# Script to copy jump-app-images to quay
##

## Params
REGISTRY_SERVER=quay.io
REGISTRY_PROJECT=acidonpe
REGISTRY=$REGISTRY_SERVER/$REGISTRY_PROJECT

## Imagestreams Jump App
IS="back-golang
back-springboot
back-quarkus
back-python
front-javascript"

## Publish internal registry 
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
sleep 20

## Login registries
HOST=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
podman login -u kubeadmin -p $(oc whoami -t) --tls-verify=false $HOST 
podman login $REGISTRY_SERVER

## Pull Jump App images
for i in $IS
do
  skopeo copy docker://$HOST/jump-app-cicd-grpc/$i:develop docker://$REGISTRY/jump-app-$i-grpc:latest --src-tls-verify=false
done

