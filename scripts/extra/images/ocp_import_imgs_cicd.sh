#!/bin/bash
##
# Script to import images from a extenal registry
##

## Params
NS=jump-app-cicd
REGISTRY=quay.io/acidonpe

## Imagestreams Jump App
IS="back-golang
back-springboot
back-quarkus
back-python
front-javascript"

oc new-project $NS

## Import Jump App images
for i in $IS
do
  oc import-image $i --from=$REGISTRY/jump-app-$i:latest --confirm -n $NS
  oc tag $i:latest $i:develop -n $NS
done

cat <<EOF > /tmp/image-pullers-everyone.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: image-pullers-everyone
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:image-puller
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: system:serviceaccounts
EOF

oc apply -f /tmp/image-pullers-everyone.yaml -n $NS
