kubectl port-forward svc/jenkins-service -n devops-tools 8081:8081

### use ngrok to enable auto trigger of pipelines
$ brew install ngrok
$ ngrok config add-authtoken <authtoken>
$ ngrok http 8081

Note:
- In github repo, go setting then webhook
    https://<ngrok URL>/github-webhook/
    content-type: application/json
    Enable SSL verification
    Just the push event
- In Jenins, no need to setup Jenkins URL, and allow anoymous access (security)
- In Jenkins, when adding source to multibranch pipeline, make sure to select Github and NOT git