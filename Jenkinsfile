pipeline {
    // agent any

    agent {
        kubernetes {
            yamlFile 'jenkins-local/jenkins-05-dindPod.yaml'
        }
    }

    tools {
        maven 'Maven 3.9.14'
    }

    environment {
        IMAGE_NAME = 'isji/rest-api-demo'
    }

    stages {

        stage('Prepare') {
            steps {
                script {
                    env.SHORT_SHA = env.GIT_COMMIT.take(7)
                }
            }
}
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Deploy to Nexus') {
            steps {
                dir('rest-api-demo') {
                    withCredentials([usernamePassword(
                        credentialsId: 'nexus-creds',
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASS'
                    )]) {
                        sh 'ls -al'
                        sh '''
                        mvn clean deploy \
                        --settings ./settings.xml
                        '''
                    }
                }
            }
        }

        stage('Build Image') {
            parallel {
                stage('Build Docker Image') {
                    steps {
                        container('shell') {
                            sh '''
                            docker build -f app-deployment/Dockerfile \
                            -t $IMAGE_NAME:$SHORT_SHA \
                            -t $IMAGE_NAME:latest .
                            '''
                        }
                    }
                }

                stage('Build Podman Image') {
                    steps {
                        container('podman') {
                            sh '''
                            podman --storage-driver=vfs build \
                            -f app-deployment/Containerfile \
                            -t $IMAGE_NAME:$SHORT_SHA-podman \
                            -t $IMAGE_NAME:latest-podman .
                            '''
                        }
                    }
                }
            
            }
        }
        
 
        stage('Push Docker Image') {
            steps {
                container('shell') {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'USER',
                        passwordVariable: 'PASS'
                    )]) {
                        sh '''
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push $IMAGE_NAME:$SHORT_SHA
                        docker push $IMAGE_NAME:latest
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('shell') {
                    sh "sed -i 's|BUILD_NUMBER_PLACEHOLDER|${SHORT_SHA}|g' app-deployment/k8s-deployment.yaml"
                    sh "cat app-deployment/k8s-deployment.yaml"
                }
                
                container('shell') {
                    sh '''
                        kubectl apply -f app-deployment/k8s-deployment.yaml -n devops-tools
                        kubectl rollout status deployment/rest-api-app -n devops-tools
                    '''
                }
            }
        }

        stage('Testing') {
            steps {
                echo 'Testing API endpoints...'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}