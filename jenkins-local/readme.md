kubectl port-forward svc/jenkins-service -n devops-tools 8081:8081

### use ngrok to enable auto trigger of pipelines
$ brew install ngrok
$ ngrok config add-authtoken <authtoken>
$ ngrok http 8081

Note: In Jenins, no need to setup Jenkins URL, and allow anoymous access (security)