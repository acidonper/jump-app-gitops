# Federate Red Hat Service Mesh

## Introduction

This folder contains the required files to create and configure a service mesh federated scenario between a couple of clusters.

## Steps

From an overall process point of view, the procedure includes the following steps:

- Create control plane
- Test all components in the respective control plane
- Create manually the respective configmap istio-ca-root-cert in the federated cluster with the respective name (E.g _istio-ca-root-cert_ in cluster1-mesh1 as _cluster1-mesh1-ca-root-cert_ in cluster2-mesh1)
- Create the ServiceMeshPeer objects in each cluster (_*It is required to obtain the public URL of the egress gateway's service created for the federated peer in each cluster_)
- Create the ExportedServiceSet object in the cluster that has the respective services
- Import the ImportedServiceSet object in the cluster that has to consume the respective services

Please, review [setup_istio_federated.sh](../../../extra/setup_istio_federated.sh) to execute the procedure automatically in a AWS scenario.

## Extra

### DNS

DNS sidecar proxy support is available for preview in Istio 1.8. This provides DNS interception for all workloads with a sidecar, allowing Istio to perform DNS lookup on behalf of the application.

Please visit the following [link](https://istio.io/latest/blog/2020/dns-proxy/) for more information.

## Author Information

Asier Cidon

asier.cidon@gmail.com
