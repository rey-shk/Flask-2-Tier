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
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Running SonarQube Code Analysis...'
                withSonarQubeEnv('sonar-demo') {
                    sh '''
                        docker run --rm \
                          -e SONAR_HOST_URL="${SONAR_HOST_URL}" \
                          -e SONAR_TOKEN="${SONAR_AUTH_TOKEN}" \
                          -v "${WORKSPACE}:/usr/src" \
                          sonarsource/sonar-scanner-cli \
                          -Dsonar.projectKey=flask-2-tier \
                          -Dsonar.projectName="Flask-2-Tier" \
                          -Dsonar.sources=.
                    '''
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                echo 'Running OWASP Dependency-Check on dependencies...'
                sh '''
                    docker run --rm \
                      -v "${WORKSPACE}:/src" \
                      owasp/dependency-check \
                      --scan /src \
                      --format "ALL" \
                      --out /src/dependency-check-report \
                      --failOnCVSS 7 || true
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
                      -v "${WORKSPACE}/.trivy-cache:/root/.cache/" \
                      aquasec/trivy:latest image \
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
