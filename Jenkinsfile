pipeline {
    // agent any

    // agent {
    //     kubernetes {
    //     yaml """
    //         apiVersion: v1
    //         kind: Pod
    //         spec:
    //         containers:
    //         - name: kaniko
    //           image: gcr.io/kaniko-project/executor:debug
    //           command: ["sleep"]
    //           args: ["9999999"]
    //           volumeMounts:
    //           - name: docker-config
    //             mountPath: /kaniko/.docker
    //         volumes:
    //         - name: docker-config
    //           secret:
    //             secretName: docker-config
    //             items:
    //             - key: .dockerconfigjson
    //               path: config.json
    //     """
    //     }
    // }

    agent {
        kubernetes {
            yamlFile 'jenkins-local/jenkins-05-kanikoPod.yaml'
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

        stage('Build') {
            steps {
                container('shell') {
                sh 'docker build -t isji/myapp:${BUILD_NUMBER} .'
                }
            }
        }
 
        stage('Push') {
            steps {
                container('shell') {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'USER',
                        passwordVariable: 'PASS'
                    )]) {
                        sh '''
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push isji/myapp:${BUILD_NUMBER}
                        '''
                    }
                }
            }
        }

        

        // stage('Debug') {
        //     steps {
        //         container('kaniko') {
        //             echo "Workspace is: ${WORKSPACE}"
        //         }
        //     }
        // }

        // stage('Build and Push Docker') {
        //     steps {
        //         container('kaniko') {
        //             script {
        //                 sh(script: '/kaniko/executor --context=dir:///home/jenkins/agent/workspace/springboot-pipeline_main/app-deployment --dockerfile=Dockerfile --destination=isji/myapp:1 --verbosity=info', label: 'Kaniko Build')
        //             }
        //         }
        //     }
        // }

        // stage('Build Docker') {
        //     steps {
        //         container('kaniko') {
        //             sh '''
        //                 /kaniko/executor \
        //                 --context=${WORKSPACE}/rest-api-demo \
        //                 --dockerfile=${WORKSPACE}/app-deployment/Dockerfile \
        //                 --destination=${IMAGE_NAME} \
        //                 --verbosity=info
        //             '''
        //         }
        //     }
        // }

        // stage('Build Docker') {
        //     steps {
        //         sh '''
        //         docker build -f docker/Dockerfile \
        //         -t $IMAGE_NAME:$SHORT_SHA \
        //         -t $IMAGE_NAME:latest .
        //         '''
        //     }
        // }

        // stage('Push to Dockerhub ') {
        //     steps {
        //         withCredentials([usernamePassword(
        //             credentialsId: 'dockerhub-creds',
        //             usernameVariable: 'DOCKER_USER',
        //             passwordVariable: 'DOCKER_PASS'
        //         )]) {
        //             sh '''
        //             echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

        //             docker push $IMAGE_NAME:$SHORT_SHA
        //             docker push $IMAGE_NAME:latest
        //             '''
        //         }
        //     }
        // }

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