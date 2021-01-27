#!/bin/bash
##
# Setup Openshift Environment
##

# Create Namespaces in order to deploy applications
oc new-project jump-app-dev
oc new-project jump-app-pre
oc new-project jump-app-pro

# Create CI/CD Namespace 
oc new-project jump-app-cicd

# Deploy CI/CD solution
oc new-project gitops-argocd

# Warning messages
read -p "Are you sure ArgoCD Operator is installed on gitops namespace? Press enter to continue..."
read -p "Are you sure Service Mesh Operators are installed on istio-system namespace (*If ServiceMesh is enabled)? Press enter to continue..."

# Apply chart template
helm template ./charts/jump-app-argocd --debug --namespace gitops-argocd | oc apply -f -
