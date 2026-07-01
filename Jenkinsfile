pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS_ID = 'dockerhub-credentials'
        DOCKER_USER                = 'vnit2075' // Change to your actual Docker Hub username
        IMAGE_NAME                 = 'audi-showroom'
        IMAGE_TAG                  = "${BUILD_NUMBER}"
        FULL_IMAGE_NAME            = "${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout code from git repository
                checkout scm
            }
        }

        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_HUB_CREDENTIALS_ID) {
                        def customImage = docker.build(FULL_IMAGE_NAME)
                        customImage.push()
                    }
                }
            }
        }

        stage('Fix Manifest Mismatch') {
            steps {
                // Fix the script's namespace.yml expectation
                sh 'cp k8s/namespace.yaml k8s/namespace.yml || true'
            }
        }

        stage('Deploy MySQL Database') {
            steps {
                // Deploy MySQL StatefulSet first (runs script that auto-locates Kubeconfig)
                sh 'chmod +x scripts/mysql.sh'
                sh './scripts/mysql.sh deploy'
            }
        }

        stage('Blue-Green Deploy Web App') {
            steps {
                sh 'chmod +x scripts/app.sh'
                // Execute the blue-green script with the new image
                sh "./scripts/app.sh deploy ${FULL_IMAGE_NAME}"
            }
        }
    }

    post {
        success {
            echo "Successfully deployed version ${IMAGE_TAG} to Kubernetes!"
        }
        failure {
            echo "Deployment failed. Please check build logs."
        }
    }
}
