# Jump App Gitops

## Introduction

*Jump App GitOps* is one of a set of repositories developed to generate a microservice based application, named _Jump App_. This repository includes an automated way of deploy _Jump App's_ microservices and all stuff around this application (Deployments, Services, Build Configs, Pipelines, etc), including optionally CI/CD or Service Mesh objects as well. 

As probably known, this automated "tool" is based on helm and tries to integrate the following solutions:

- Red Hat Openshift Container Platform 4 (\*Kubernetes)
- Multi programing language microservices (Javascript, Golang, Python, Quarkus and Java)
- GitOps solution based on ArgoCD
- CI/CD strategy based Tekton
- Service Mesh architecture based on Istio
- Serverless integration based on Knative

This repository was created to include all automated procedures to achieve the following goals:

- Create required namespaces in Kubernetes (istio-system, jump-app-cicd, jump-app-dev, jump-app-pre and jump-app-pro)
- Install required ArgoCD objects (ArgoCD Server, Route, Rolebindings and Applications)
- Deploy CI/CD objects in jump-app-cicd namespace (Imagestreams, BuildConfigs, Tekton Pipelines, etc)
- Deploy _Jump App's_ microservices in each environment/namespace
- Create Service Mesh objects when Istio support is enabled
- Create Serverless services when Knative support is enabled

_NOTE:_ It is important to know that it is possible to activate/deactivate features through the variable _enabled_ defined for each sub-chart in the global _values.yaml_ file.

## Requisites

In order to start working with this repository, it is required:

- A Red Hat Openshift Container Platform Cluster +4.7
- Helm client installed in the local machine (Please follow https://helm.sh/docs/intro/install/ for more information)

The setting up process manage the following dependencies automatically depending on the argument provided:

- Install ArgoCD Operator
- Install Red Hat Openshift Pipelines Operator
- Install Red Hat Serverless Operator
- Install Red Hat Openshift Service Mesh Operator
- Install Kiali Operator installed provided by Red Hat
- Install Red Hat Openshift Jaeger Operator
- Apply _Service Mesh Control Plane_ Object with default configuration (*Please, find object examples in scripts/files/istio folder*)
- Apply _Service Mesh Member Roll_ Object with a test namespace (*Please, find object examples in scripts/files/istio folder*)

## Multi Branch

This repository has a set of branches in order to manage different environments configuration files in ArgoCD. If you want to modify default values, it is required access to the specific branch, modify values.yaml file and push the file to the git repository.
 
- feature/jump-app-cicd -> Tekton chart with CI/CD configuration
- feature/jump-app-dev -> Jump App chart with DEV environment configuration
- feature/jump-app-pre -> Jump App chart with PRE environment configuration
- feature/jump-app-pro -> Jump App chart with PRO environment configuration
- feature/bootstrap -> Openshift Cluster bootstrap

## Quick Start

### GitOps Approach

_Jump App_ architecture contains three environments (dev, pre and pro) where the application is deployed automatically. If the priority is making use of this solution with three environments and not waste any time, the following procedure install _Jump App_ and configure CI/CD and GitOps solutions automatically:

- Openshift login

```$bash
oc login -u <user> -p <pass> <ocp_cluster_console>
```

- Download submodules

```$bash
git submodule update --remote
```

- Modify _appsDomain_ parameter (*When it is required)

```$bash
sh scripts/extra/update_charts_domain.sh apps.mydomain.com 
```

- Execute _setup.sh_ script for installing Operator

```$bash
oc login
sh ./scripts/setup_argocd.sh
```

### Tradicional Approach

_Jump App_ architecture contains three environments (dev, pre and pro) where the application is deployed automatically. If the priority is making use of this solution with three environments and not waste any time, the following procedure install _Jump App_ and configure CI/CD and GitOps solutions automatically:

- Openshift login

```$bash
oc login -u <user> -p <pass> <ocp_cluster_console>
```

- Download submodules

```$bash
git submodule update --remote
```

- Modify _appsDomain_ parameter (*When it is required)

```$bash
sh scripts/extra/update_charts_domain.sh apps.mydomain.com 
```

- Execute _setup.sh_ script for installing Operator

```$bash
oc login
sh ./scripts/setup.sh
```

**NOTE**: It is possible to deploy Red Hat Service Mesh solution passing the following parameter to _setup.sh_ script:

```$bash
sh ./scripts/setup.sh --servicemesh
```

**NOTE**: It is possible to deploy Red Hat Serverless solution passing the following parameter to _setup.sh_ script:

```$bash
sh ./scripts/setup.sh --serverless
```

**NOTE**: It is possible to deploy Red Hat Serverless and Red Hat Service Mesh solutions passing the following parameter to _setup.sh_ script:

```$bash
sh ./scripts/setup.sh --serverless --servicemesh
```

**IMPORTANT**: By default, some namespaces will be created (_istio-system_, _jump-app-cicd_, _jump-app-dev_, _jump-app-pre_ and _jump-app-pro_). If it is required to modify their names, take special attention to modify associated variables and define the new names correctly.

### Custom Installation

When it is required to modify Jump App installation in order to customize the number of environments, for example, it is required to modify *./scripts/files/values-argocd.yaml* file in order to specify these requirements.

#### E.g. Deploy ArgoCD and CI/CD elements

```$bash
vi scripts/files/values-argocd.yaml

##
# Jump App ArgoCD Chart values
##

# Helm Repo GIT
helmRepoUrl: https://github.com/acidonper/jump-app-gitops.git

# ArgoCD apps definition
apps:
  jump-app-cicd:
    branch: feature/jump-app-cicd 
    enabled: true
  jump-app-pro:
    branch: feature/jump-app-pro
    enabled: false
  jump-app-pre:
    branch: feature/jump-app-pre
    enabled: false
  jump-app-dev:
    branch: feature/jump-app-dev 
    enabled: false
...
```

```$bash
oc login
sh ./scripts/setup.sh
```

#### E.g. Deploy ArgoCD, CI/CD elements and DEV environment

```$bash
vi scripts/files/values-argocd.yaml

##
# Jump App ArgoCD Chart values
##

# Helm Repo GIT
helmRepoUrl: https://github.com/acidonper/jump-app-gitops.git

# ArgoCD apps definition
apps:
  jump-app-cicd:
    branch: feature/jump-app-cicd 
    enabled: true
  jump-app-pro:
    branch: feature/jump-app-pro
    enabled: false
  jump-app-pre:
    branch: feature/jump-app-pre
    enabled: false
  jump-app-dev:
    branch: feature/jump-app-dev 
    enabled: true
...
```

```$bash
oc login
sh ./scripts/setup.sh
```

### Local CRC Installation (CodeReady Containers)

CodeReady Containers brings a minimal, preconfigured OpenShift cluster to your local laptop or desktop computer for development and testing purposes. CodeReady Containers supports native hypervisors for Linux, macOS, and Windows 10. You can download CodeReady Containers from the [Red Hat CodeReady Containers product page](https://developers.redhat.com/products/codeready-containers).

_Jump App_ architecture could be deployed in CRC using the following procedure:

- Openshift login

```$bash
oc login -u <user> -p <pass> <ocp_cluster_console>
```

- Download submodules

```$bash
git clone --recursive https://github.com/acidonper/jump-app-gitops.git
```

- Execute _setup.sh_ script for installing Operator

```$bash
oc login
sh ./scripts/setup_crc.sh
```

**NOTE**: It is important to bear in mind that *Jump App* CRC deployment configuration is located in scripts/files/values-argocd.yaml and ArgoCD is using *crc-cicd* and *cicd* branches to deploy _Jump App CI/CD solution_ and a single environment respectively. 

## ArgoCD

### Access Console

Once ArgoCD Server is installed, it is possible access ArgoCD Web UI follow next procedure:

- Obtain admin password and ArgoCD Server URL

```$bash
oc login
oc get secret openshift-gitops-cluster -o jsonpath='{.data.admin\.password}' -n openshift-gitops | base64 -d
oc get route openshift-gitops-server -n openshift-gitops
openshift-gitops-server-openshift-gitops.apps.<mydomain>
```

NOTE: It is possible to access via Openshift OAuth
### ArgoCD CLI

- Auth ArgoCD Server using CLI

```$bash
oc port-forward service/argocd-server 8888:443
argocd login 127.0.0.1:8888 --username admin --password xxxx
```

- List ArgoCD Apps

```$bash
argocd app list
```

- Sync ArgoCD Apps current state

```$bash
argocd app sync jump-app-dev
```

## Service Mesh

Red Hat Service Mesh is installed to implement a mesh in Openshift based on Istio. The mesh architecture in this implementation has been design for implementing a unified control plane in a single Openshift cluster.

### Service Mesh Federation

When it is required to implement multi cluster environments to provide high availability and/or balance the load between a set of clusters, it is possible to deploy multi mesh architectures using *mesh federation*. 

Please visit the following [link](scripts/files/istio/federated/README.md) for more information about *Red Hat Service Mesh Federation*.

## Charts Tests

### Jump App ArgoCD

```$bash
helm template ./charts/jump-app-argocd -f examples/local/values-jump-app-argocd.yaml --debug --namespace openshift-gitops
```

### Jump App CI/CD

```$bash
helm template ./charts/jump-app-cicd -f examples/local/values-jump-app-cicd.yaml --namespace jump-app-cicd
```

### Jump App

- DEV

```$bash
helm template ./charts/jump-app-micros -f examples/local/values-jump-app-dev.yaml --namespace jump-app-dev
```

## Author Information

Asier Cidon

asier.cidon@gmail.com
