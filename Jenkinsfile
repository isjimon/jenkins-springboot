pipeline {
    agent any

    tools {
        maven 'Maven 3.9.14'

    }

    stages {
        stage('Build app') {
            steps {
                echo 'Building java app via maven tool...'
                sh 'cd rest-api-demo'
                sh 'mvn -B -DskipTests clean package'
            }
        }

        stage('Push App') {
            steps {
                echo 'Pushing jar file to nexus...'
            }
        }

        stage('Build Docker') {
            steps {
                echo 'Building Docker image...'
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to DockerHub...'
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