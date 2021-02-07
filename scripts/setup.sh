#!/bin/bash
##
# Setup Openshift Environment
##

echo "Setting Up Jump App stuff in Openshift..."

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

# Install Operators
echo "Installing ArgoCD operator..."
oc apply -f ./scripts/files/operators/argocd.yaml
sleep 30
echo "Installing Tekton operator..."
oc apply -f ./scripts/files/operators/tekton.yaml
sleep 30

if [ ! -z "$1" ] &&  [ $1 == '--servicemesh' ]
then

    echo "Creating istio namespace..."
    # Create Istio Namespace
    oc new-project istio-system

    echo "Installing Istio operator..."
    oc apply -f ./scripts/files/operators/istio.yaml
    sleep 30

    # Wait for Istio Operator are ready
    echo "Waiting for Istio Operators is ready..."
    sleep 60

    # Aplying Controlplane and Memberrole objects
    echo "Installing Istio Control Plane..."
    oc apply -f ./scripts/files/istio/istio-controlplane.yaml
    oc apply -f ./scripts/files/istio/istio-memberrole.yaml

fi

# Wait time to install operators
echo "Waiting for Operators are ready..."
sleep 60

# Apply chart template
echo "Creating ArgoCD Server, project, CI/CD Application and so on..."
oc project gitops-argocd
helm template ./charts/jump-app-argocd -f ./scripts/files/values-argocd.yaml --debug --namespace gitops-argocd | oc apply -f -
sleep 10

# Notifications
read -p "Please configure GitHub weebhooks in order to notify code changes to Tekton automatically..."
