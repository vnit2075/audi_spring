pipeline {
    agent any

    environment {
        // Change to your actual Docker Hub username
        DOCKER_HUB_USER = 'vnit2075' 
        IMAGE_NAME      = 'audi-showroom'
        IMAGE_TAG       = "${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"
        // Kubeconfig path on Jenkins host
        KUBECONFIG_PATH = '/var/lib/jenkins/kubeconfig.yml'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${IMAGE_TAG} ."
            }
        }

        stage('Login to Docker Hub') {
            steps {
                echo 'Logging into Docker Hub...'
                // Using your existing Jenkins Credential ID 'dockerhub-credentials'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                echo "Pushing Docker image ${IMAGE_TAG} to registry..."
                sh "docker push ${IMAGE_TAG}"
            }
        }

        stage('Deploy Database') {
            steps {
                echo 'Deploying MySQL database to Kubernetes...'
                sh "export KUBECONFIG=${KUBECONFIG_PATH} && ./scripts/mysql.sh deploy"
            }
        }

        stage('Blue-Green Deployment') {
            steps {
                echo 'Executing Blue-Green deployment swap...'
                sh "export KUBECONFIG=${KUBECONFIG_PATH} && ./scripts/app.sh deploy ${IMAGE_TAG}"
            }
        }
    }

    post {
        always {
            echo 'Cleaning up local Docker images...'
            sh "docker rmi ${IMAGE_TAG} || true"
            sh "docker logout || true"
        }
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed. Please check logs.'
        }
    }
}
