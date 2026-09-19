pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Pulling source code from GitHub...'
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/rey-shk/Flask-2-Tier.git']]
                ])
                // Clean up root-owned cache from any previous runs
                sh 'docker run --rm -v "${WORKSPACE}:/src" alpine rm -rf /src/.trivy-cache || true'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Running SonarQube Analysis via Docker container...'
                withSonarQubeEnv('sonarqube') {
                    sh '''
                        docker run --rm \
                          -e SONAR_HOST_URL="${SONAR_HOST_URL}" \
                          -e SONAR_TOKEN="${SONAR_AUTH_TOKEN}" \
                          -v "${WORKSPACE}:/usr/src" \
                          sonarsource/sonar-scanner-cli \
                          -Dsonar.projectKey=flask-2-tier \
                          -Dsonar.projectName="Flask-2-Tier" \
                          -Dsonar.sources=. \
                          -Dsonar.exclusions="**/.trivy-cache/**"
                    '''
                }
            }
        }

        // Option 2: Software Composition Analysis (SCA) via Trivy (No NVD required)
        stage('Trivy Dependency (SCA) Scan') {
            steps {
                echo 'Scanning dependencies for vulnerabilities with Trivy (SCA)...'
                sh '''
                    docker run --rm \
                      -v "${WORKSPACE}:/src" \
                      -v trivy-cache:/root/.cache/ \
                      aquasec/trivy:latest fs \
                      --exit-code 0 \
                      --severity HIGH,CRITICAL \
                      /src/requirements.txt
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t flask-app:latest .'
            }
        }

        stage('Trivy Image Vulnerability Scan') {
            steps {
                echo 'Scanning Docker image for vulnerabilities with Trivy...'
                sh '''
                    docker run --rm \
                      -v /var/run/docker.sock:/var/run/docker.sock \
                      -v trivy-cache:/root/.cache/ \
                      aquasec/trivy:latest image \
                      --exit-code 0 \
                      --severity HIGH,CRITICAL \
                      flask-app:latest
                '''
            }
        }

        stage('Run Docker Container') {
            steps {
                echo 'Deploying Docker container...'
                sh '''
                    # Stop and remove existing container if running
                    docker stop flask-app-container || true
                    docker rm flask-app-container || true

                    # Run new container
                    docker run -d --name flask-app-container -p 5000:5000 flask-app:latest
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution complete.'
        }
    }
}