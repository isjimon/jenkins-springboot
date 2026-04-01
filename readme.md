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



## Components

### /jenkins-local

Deploy jenkins on local Kind cluster
```
$ kubectl apply -f /jenkins-local
```
Expose on service and access it on localhost:8081
``` 
$ kubectl port-forward svc/jenkins-service -n devops-tools 8081:8081
```

Enable auto trigger of pipelines in Jenkins

1. Use ngrok to expose jenkins publicly
```
$ brew install ngrok
$ ngrok config add-authtoken <authtoken>
$ ngrok http 8081
```

Note:
- In github repo, go setting then webhook
```
    https://<ngrok URL>/github-webhook/
    content-type: application/json
    Enable SSL verification
    Just the push event
```
- In Jenkins, no need to setup Jenkins URL, and allow anoymous access (security)
- In Jenkins, when adding source to multibranch pipeline, make sure to select Github and NOT git
- For maven, install mvn plugin to use mvn commands on pipeline


### /nexus
Run nexus on local machine
```
$ cd nexus/
$ docker compose up -d
```

- Username: admin
- Password: <generated admin password located at: /nexus-data/admin.password>

Reference: https://hub.docker.com/r/sonatype/nexus3

### /rest-api-demo
build jar file at rest-api-demo/target/rest-api-demo-0.0.1-SNAPSHOT.jar
```
$ mvn clean install
```

depoy to nexus
update pom.xml, add these lines. For the ip:  `$ ipconfig getifaddr en0`
```
	<distributionManagement>
		<repository>
			<id>nexus</id>
			<url> http://<ip>/repository/maven-snapshots/ </url>
		</repository>
	</distributionManagement>
```
```
$ export NEXUS_USER=admin
$ export NEXUS_PASS=password
$ mvn deploy --settings ./settings.xml
```
```
$ NEXUS_USER=admin NEXUS_PASS=password mvn deploy --settings ./settings.xml
```

## /app-deployment
```
$ docker build -t isji/rest-api-demo .
$ docker build -t isji/rest-api-demo:1 -f app-deployment/Dockerfile .
$ docker run -p 8080:8080 isji/rest-api-demo

```


docker login
kubectl create secret generic docker-config \
  --from-file=.dockerconfigjson=$HOME/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson