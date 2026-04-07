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
                echo 'Deploying app to Kubernetes cluster...'
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