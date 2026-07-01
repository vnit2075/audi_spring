pipeline {
    agent any

    environment {
        // Point compilation explicitly to Java 17 (installed in Phase 1)
        JAVA_HOME                 = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH                      = "${env.JAVA_HOME}/bin:${env.PATH}"
        
        DOCKER_HUB_CREDENTIALS_ID = 'dockerhub-credentials'
        DOCKER_USER                = 'vnit2075' // Change to your actual Docker Hub username
        IMAGE_NAME                 = 'audi-showroom'
        IMAGE_TAG                  = "${BUILD_NUMBER}"
        FULL_IMAGE_NAME            = "${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Java Version') {
            steps {
                // This will print Java 17 in the console output to verify compilation toolchain
                sh 'java -version'
            }
        }

        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: env.DOCKER_HUB_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER_VAR', passwordVariable: 'DOCKER_PASS_VAR')]) {
                    sh 'echo "$DOCKER_PASS_VAR" | docker login -u "$DOCKER_USER_VAR" --password-stdin'
                    sh "docker build -t ${FULL_IMAGE_NAME} ."
                    sh "docker push ${FULL_IMAGE_NAME}"
                    sh 'docker logout'
                }
            }
        }

        stage('Fix Manifest Mismatch') {
            steps {
                sh 'cp k8s/namespace.yaml k8s/namespace.yml || true'
            }
        }

        stage('Deploy MySQL Database') {
            steps {
                sh 'chmod +x scripts/mysql.sh'
                sh './scripts/mysql.sh deploy'
            }
        }

        stage('Blue-Green Deploy Web App') {
            steps {
                sh 'chmod +x scripts/app.sh'
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
