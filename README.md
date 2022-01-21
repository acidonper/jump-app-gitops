# Jump App Kustomize

## Introduction

*Jump App GitOps* is one of a set of repositories developed to generate a microservice based application, named _Jump App_. This repository includes an automated way of deploy _Jump App's_ microservices and all stuff around this application (Deployments, Services, Build Configs, Pipelines, etc), including optionally CI/CD or Service Mesh objects as well.

## Kustomize Tests

### Development

- Jump App

```$bash
kustomize build kustomize/dev/jump-app
```

- Jump App (*Quay Images*)

```$bash
kustomize build kustomize/dev/jump-app-quay
```

- Jump App + Istio Support

```$bash
kustomize build kustomize/dev/jump-app-mesh
```

## Author Information

Asier Cidon

asier.cidon@gmail.com
