#!/bin/bash
##
# Setup Openshift Environment
##

echo "Setting Up Jump App stuff in Openshift..."

# Install Operators
echo "Installing ArgoCD operator..."
helm template ./charts/jump-app-ocp-bootstrap -f ./scripts/files/values-bootstrap-gitops.yaml --debug | oc apply -f -
sleep 60

# Apply chart template
echo "Creating ArgoCD Server and Bootstrap the Openshift Cluster"
helm template ./charts/jump-app-argocd -f ./scripts/files/values-argocd-gitops.yaml --debug --namespace openshift-gitops | oc apply -f - -n openshift-gitops

# Notifications
read -p "Openshift Cluster bootstrap finished"
