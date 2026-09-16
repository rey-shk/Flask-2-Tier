pipeline {
    agent any

    environment {
        // Docker image name (adjust if needed)
        IMAGE_NAME = 'myapp:latest'
    }

    options {
        // Keep the last 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        // Abort if the pipeline runs longer than 30 minutes
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                // Pull source code from the repository
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the image using the Dockerfile at the repo root
                    sh "docker build -t ${env.IMAGE_NAME} ."
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    // Run docker‑compose (expects docker-compose.yml in repo root)
                    sh "docker compose up -d --remove-orphans"
                }
            }
        }
    }

    post {
        always {
            // Clean up dangling images & containers on the runner
            sh "docker system prune -f"
        }
        success {
            echo '🚀 Deployment succeeded.'
        }
        failure {
            echo '❗ Deployment failed.'
        }
    }
}