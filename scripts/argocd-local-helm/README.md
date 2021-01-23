# Jump App ArgoCD Local Chart

## Introduction

*Jump App ArgoCD Local* chart deploys Jump App's argocd objects in order to deploy Jump App and CI/CD objects. The following objects will be managed by this chart:

- ClusterRoleBindings
- ArgoCD Server
- Projects
- Applications

## Install

- Install Helm Chart applying objects in kubernetes

```$bash
oc project gitops-argocd
helm template . --debug | oc apply -f -
```

## Local Tests

- Lint

```$bash
$ helm lint
```

- Render templates Locally

```$bash
$ helm template . --debug
```

## Author Information

Asier Cidon

asier.cidon@gmail.com