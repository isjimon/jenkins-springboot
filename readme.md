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

Additional Configuration
1. Install Kubernetes plugin in Jenkins
2. Install Kubernetes CLI plugin in Jenkins
3. Configure k8s on jenkins. config > cloud > kubernetes. 
    - Kubernetes URL: https://kubernetes.default.svc
    - Jenkins URL: http://jenkins-service.devops-tools.svc.cluster.local:8081
    - Jenkins Tunnel: jenkins-service.devops-tools.svc.cluster.local:50000    

Enable auto trigger of pipelines in Jenkins

1. Use ngrok to expose jenkins publicly
```
$ brew install ngrok
$ ngrok config add-authtoken <authtoken>
$ ngrok http 8081
```

2. In github repo, go setting then webhook
```
    https://<ngrok URL>/github-webhook/
    content-type: application/json
    Enable SSL verification
    Just the push event
```

Additional Notes:
- In Jenkins, no need to setup Jenkins URL, and allow anoymous access (security)
- In Jenkins, when adding source to multibranch pipeline, make sure to select Github and NOT git
- For maven, install mvn plugin to use mvn commands on pipeline
- Check if jenkins can create pods: `$ kubectl auth can-i create pods --as=system:serviceaccount:devops-tools:jenkins-admin`
- Adding of logs: `$ kubectl set env deployment/jenkins \
  JAVA_OPTS="-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true" \
  -n devops-tools`


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
Manual build of docker image: `$ docker build -t isji/rest-api-demo:latest -f app-deployment/Dockerfile .`

Manual run of docker image: `$ docker run -p 8080:8080 isji/rest-api-demo:latest`

Local access: `access http://localhost:8080/api/hello`

kubectl create clusterrolebinding jenkins-deploy \
  --clusterrole=cluster-admin \
  --serviceaccount=devops-tools:default