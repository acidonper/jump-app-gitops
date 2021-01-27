#!/bin/bash
##
# Setup Openshift Environment
##

# Create Namespaces in order to deploy applications
oc new-project jump-app-dev
oc new-project jump-app-pre
oc new-project jump-app-pro

# Create ArgoCD Namespace
oc new-project gitops-argocd

# Create CI/CD Namespace 
oc new-project jump-app-cicd

# Create Istio Namespace
oc new-project istio-system

# Install Operators
oc apply -f ./examples/operators/argocd.yaml
oc apply -f ./examples/operators/tekton.yaml
oc apply -f ./examples/operators/istio.yaml

# Apply chart template
helm template ./charts/jump-app-argocd --debug --namespace gitops-argocd | oc apply -f -
