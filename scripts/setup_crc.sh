#!/bin/bash
##
# Setup Openshift Environment
##
echo "Setting Up Jump App stuff..."

# Create Namespaces in order to deploy applications
echo "Creating namespaces..."
sleep 10
# Create Jump App Namespaces
oc new-project jump-app-dev
oc new-project jump-app-pre
oc new-project jump-app-pro
# Create CI/CD Namespace 
oc new-project jump-app-cicd
# Create ArgoCD Namespace
oc new-project gitops-argocd
# Create Istio Namespace
oc new-project istio-system

# Install Operators
echo "Installing ArgoCD operator..."
oc apply -f ./examples/operators/argocd.yaml
sleep 60
echo "Installing Tekton operator..."
oc apply -f ./examples/operators/tekton.yaml
sleep 60
echo "Installing Istio operator..."
oc apply -f ./examples/operators/istio.yaml
sleep 60

# Wait time to install operators
echo "Waiting for Operators are ready..."
sleep 60

# Apply chart template
echo "Creating ArgoCD Server, project, CI/CD Application and so on..."
oc project gitops-argocd
helm template ./charts/jump-app-argocd -f ./scripts/files/crc-values-argocd.yaml --debug --namespace gitops-argocd | oc apply -f -
sleep 10

# Notifications
read -p "Please configure GitHub weebhooks in order to notify code changes to Tekton automatically..."
