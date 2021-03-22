# Jump App Charts

## Introduction

*Jump App GitOps* is one of a set of repositories developed to generate a microservice based application, named _Jump App_. This repository includes an automated way of deploy _Jump App's_ microservices and all stuff around this application (Deployments, Services, Build Configs, Pipelines, etc), including optionally CI/CD or Service Mesh objects as well. 

## Charts Tests

### Jump App

- DEV

```$bash
helm template . -f values.yaml --namespace jump-app-dev
```

## Author Information

Asier Cidon

asier.cidon@gmail.com
