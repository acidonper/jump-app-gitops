#!/bin/bash
#
# Creating Istio ControlPlane and MemberRole
#

# Create Service Mesh Namespaces
oc new-project istio-system

# Aplying Controlplane and Memberrole objects
oc apply -f ./examples/istio-controlplane.yaml
oc apply -f ./examples/istio-memberrole.yaml