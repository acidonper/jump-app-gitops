#!/bin/bash
#
# Creating Istio ControlPlane and MemberRole
#

# Warning messages
read -p "Are you sure Service Mesh Operators are installed on istio-system namespace (*If ServiceMesh is enabled)? Press enter to continue..."

# Aplying Controlplane and Memberrole objects
oc apply -f ./examples/istio-controlplane.yaml
oc apply -f ./examples/istio-memberrole.yaml