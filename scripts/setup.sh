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
oc label namespace jump-app-dev argocd.argoproj.io/managed-by=gitops-argocd --overwrite
oc new-project jump-app-pre
oc label namespace jump-app-pre argocd.argoproj.io/managed-by=gitops-argocd --overwrite
oc new-project jump-app-pro
oc label namespace jump-app-pro argocd.argoproj.io/managed-by=gitops-argocd --overwrite
# Create CI/CD Namespace 
oc new-project jump-app-cicd
oc label namespace jump-app-cicd argocd.argoproj.io/managed-by=gitops-argocd --overwrite
# Create ArgoCD Namespace
oc new-project gitops-argocd

waitoperatorpod() {
  sleep 10
  oc get pods -n openshift-operators | grep ${1} | awk '{print "oc wait --for condition=Ready -n openshift-operators pod/" $1 " --timeout 300s"}' | sh
  sleep 20
}

waitknativeserving() {
  sleep 10
  oc get pods -n knative-serving | grep ${1} | awk '{print "oc wait --for condition=Ready -n knative-serving pod/" $1 " --timeout 300s"}' | sh
  sleep 20
}

# Install Operators
echo "Installing ArgoCD operator..."
oc apply -f ./scripts/files/operators/argocd.yaml
waitoperatorpod gitops

echo "Installing Tekton operator..."
oc apply -f ./scripts/files/operators/tekton.yaml
waitoperatorpod pipelines

if [[ $@ == *"--servicemesh"* ]]
then

    echo "Creating istio namespace..."
    # Create Istio Namespace
    oc new-project istio-system
    oc label namespace istio-system argocd.argoproj.io/managed-by=gitops-argocd --overwrite
    oc new-project mesh-test

    echo "Installing Istio operator..."
    oc apply -f ./scripts/files/operators/istio.yaml
    sleep 30

    # Wait for Istio Operator are ready
    echo "Waiting for Istio Operators is ready..."
    waitoperatorpod kiali
    waitoperatorpod jaeger
    waitoperatorpod istio

    # Aplying Controlplane and Memberrole objects
    echo "Installing Istio control plane..."
    oc apply -f ./scripts/files/istio/istio-controlplane.yaml
    oc apply -f ./scripts/files/istio/istio-smmr.yaml

    # Wait for Istio Operator are ready
    echo "Waiting for Istio control plane is ready..."
    oc wait --for condition=Ready -n istio-system smmr/default --timeout 300s

fi

if [[ $@ == *"--serverless"* ]]
then

    echo "Installing Knative operator..."
    oc apply -f ./scripts/files/operators/knative.yaml
    sleep 30

    # Wait for Knative Operator are ready
    echo "Waiting for Knative Operators is ready..."
    waitoperatorpod knative-operator
    waitoperatorpod knative-openshift-ingress
    waitoperatorpod knative-openshift

    # Aplying Knative Serving and Eventing objects
    echo "Installing Knative Serving and Eventing integrators..."
    oc apply -f ./scripts/files/knative/knative-serving.yaml
    # oc apply -f ./scripts/files/knative/knative-eventing.yaml
    sleep 30
    waitknativeserving activator
    waitknativeserving autoscaler
    waitknativeserving weebhook
    waitknativeserving domain
    waitknativeserving controller

    # Apply Labels
    oc label namespace knative-serving serving.knative.openshift.io/system-namespace=true
    oc label namespace knative-serving-ingress serving.knative.openshift.io/system-namespace=true

fi

# Apply chart template
echo "Creating ArgoCD Server, project, CI/CD Application and so on..."
oc project gitops-argocd
helm template ./charts/jump-app-argocd -f ./scripts/files/values-argocd.yaml --debug --namespace gitops-argocd | oc apply -f -

# Notifications
read -p "Please configure GitHub weebhooks in order to notify code changes to Tekton automatically..."
