# Project: Jenkins + Springboot

## Overview
To run jenkins pipeline locally that would deploy a simple rest api java applications

Pipeline Stages (Trigger: Push on main branch)
- Build jar via maven
- Jar / maven, push to Nexus
- Buiild docker image based on the jar file
- Push docker image to Dockerhub
- Deploy via kubenertes 

## Tools / Techs
- Pipeline: Jenkins
- Language: Java 
- Framework: Springboot
- Deployment: Docker, Kubernetes
- Repository: Nexus, Dockerhub

## Local requirements: 
Note: I'm using Macbook Pro m5

### Homebrew
```
$ echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
$ eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Docker
```
$ brew install --cask docker
```

### Kubernetes Cluster (Kind)
Install kind on local machine
```
$ brew install kind
```

Create local cluster
```
$ kind create cluster
```

