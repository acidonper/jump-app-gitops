#!/bin/bash
#
# Creating Istio ControlPlane and MemberRole
#

# Global Variables
OCP_CREDS=/tmp/.ocp_creds
MESH1_KUBECONFIG=/tmp/kubeconfig_cluster1
MESH2_KUBECONFIG=/tmp/kubeconfig_cluster2
rm ${MESH1_KUBECONFIG}
rm ${MESH2_KUBECONFIG}
MESH1_NS=cluster1-mesh1-system
MESH2_NS=cluster2-mesh1-system
MESH_TEST=mesh-test

# Read Input Parameters
if [ ! -f "${OCP_CREDS}" ]; then
    echo "Enter the cluster1 - API URL (E.g. https://api.fperea.a35a.sandbox473.opentlc.com:6443): "  
    read cluster1_api_url
    echo "export cluster1_api_url=$cluster1_api_url" >> $OCP_CREDS
    echo "Enter the cluster1 - Admin username: "
    read cluster1_username
    echo "export cluster1_username=$cluster1_username" >> $OCP_CREDS
    echo "Enter the cluster1 - Admin user password: "  
    read cluster1_password
    echo "export cluster1_password=$cluster1_password"  >> $OCP_CREDS
    echo "Enter the cluster2 - API URL (E.g. https://api.acidonpe.a35a.sandbox473.opentlc.com:6443): "  
    read cluster2_api_url
    echo "export cluster2_api_url=$cluster2_api_url"  >> $OCP_CREDS
    echo "Enter the cluster2 - Admin username: "  
    read cluster2_username
    echo "export cluster2_username=$cluster2_username"  >> $OCP_CREDS
    echo "Enter the cluster2 - Admin user password: "  
    read cluster2_password
    echo "export cluster2_password=$cluster2_password"  >> $OCP_CREDS
else
    source /tmp/.ocp_creds
fi

log() {
  echo
  echo "##### $*"
}

oc1() {
    export KUBECONFIG="${MESH1_KUBECONFIG}"
    if [ ! -f "${MESH1_KUBECONFIG}" ]; then
        touch ${MESH1_KUBECONFIG}
        oc login --username=${cluster1_username} --password=${cluster1_password} --insecure-skip-tls-verify=true ${cluster1_api_url}
        CLUSTER1_TOKEN=$(oc whoami -t)
        oc config set-credentials cluster1 --token=${CLUSTER1_TOKEN}
        oc config set-cluster cluster1 --server=${cluster1_api_url} --insecure-skip-tls-verify=true
        oc config set-context cluster1 --cluster=cluster1 --user=cluster1 --namespace=default
    fi
    oc config use-context cluster1
    oc "$@"
}

oc2() {
    export KUBECONFIG="${MESH2_KUBECONFIG}"
    if [ ! -f "${MESH2_KUBECONFIG}" ]; then
        touch ${MESH2_KUBECONFIG}
        oc login --username=${cluster2_username} --password=${cluster2_password} --insecure-skip-tls-verify=true ${cluster2_api_url}
        CLUSTER2_TOKEN=$(oc whoami -t)
        oc config set-credentials cluster2 --token=${CLUSTER2_TOKEN}
        oc config set-cluster cluster2 --server=${cluster2_api_url} --insecure-skip-tls-verify=true
        oc config set-context cluster2 --cluster=cluster2 --user=cluster2 --namespace=default 
    fi
    oc config use-context cluster2
    oc "$@"
}

log "Creating projects for mesh1"
oc1 new-project ${MESH1_NS} || true
oc1 new-project ${MESH_TEST} || true

log "Creating projects for mesh2"
oc2 new-project ${MESH2_NS} || true
oc2 new-project ${MESH_TEST} || true

log "Installing control plane for mesh1"
oc1 apply -f ../files/istio/federated/00-istio-controlplane-cluster1-mesh1.yaml -n ${MESH1_NS}
oc1 apply -f ../files/istio/federated/00-istio-smmr.yaml -n ${MESH1_NS}

log "Installing control plane for mesh2"
oc2 apply -f ../files/istio/federated/00-istio-controlplane-cluster2-mesh1.yaml -n ${MESH2_NS}
oc2 apply -f ../files/istio/federated/00-istio-smmr.yaml -n ${MESH2_NS}

log "Waiting for mesh1 installation to complete"
oc1 wait --for condition=Ready -n ${MESH1_NS} smmr/default --timeout 300s

log "Waiting for mesh2 installation to complete"
oc2 wait --for condition=Ready -n ${MESH2_NS} smmr/default --timeout 300s

log "Retrieving ingress addresses"
oc1 -n ${MESH1_NS} get svc cluster2-mesh1-ingress -o jsonpath="{.status.loadBalancer.ingress[].hostname}" | grep aws > /tmp/mesh1_address
if [ ! -s /tmp/mesh1_address ]; then
    echo "FATAL: Could not determine address for mesh2-ingress in mesh1"
    exit 1
fi

oc2 -n ${MESH2_NS} get svc cluster1-mesh1-ingress -o jsonpath="{.status.loadBalancer.ingress[].hostname}" | grep aws > /tmp/mesh2_address
if [ ! -s /tmp/mesh2_address ]; then
    echo "FATAL: Could not determine address for mesh2-ingress in mesh1"
    exit 1
fi

log "Creating ConfigMap for mesh2 in mesh1"
oc2 extract -n ${MESH2_NS} configmap/istio-ca-root-cert --confirm
oc1 create configmap cluster2-mesh1-ca-root-cert -n ${MESH1_NS} --from-file=root-cert.pem
rm root-cert.pem

log "Creating ConfigMap for mesh1 in mesh2"
oc1 extract -n ${MESH1_NS} configmap/istio-ca-root-cert --confirm
oc2 create configmap cluster1-mesh1-ca-root-cert -n ${MESH2_NS} --from-file=root-cert.pem
rm root-cert.pem

log "Creating MeshPeer for mesh2 in mesh1"
MESH2_HOST=$(cat /tmp/mesh2_address)
sed -e "s:MESH2_ADDRESS:${MESH2_HOST}:g" ../files/istio/federated/01-istio-peer-cluster1-mesh1.yaml | oc1 apply -n ${MESH1_NS} -f -

log "Creating MeshPeer for mesh1 in mesh2"
MESH1_HOST=$(cat /tmp/mesh1_address)
sed -e "s:MESH1_ADDRESS:${MESH1_HOST}:g" ../files/istio/federated/01-istio-peer-cluster2-mesh1.yaml | oc2 apply -n ${MESH2_NS} -f -

log "Creating ExportedServices for mesh2 in mesh1"
oc1 apply -f ../files/istio/federated/02-istio-export-cluster1-mesh1.yaml -n ${MESH1_NS}

log "Creating ImportedServices for mesh2 in mesh1"
oc2 apply -f ../files/istio/federated/02-istio-import-cluster2-mesh1.yaml -n ${MESH2_NS}
