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
                echo 'Running SonarQube Analysis...'
                withSonarQubeEnv(installationName: 'sonar-demo', credentialsId: 'sonar-demo') {
                    sh '''
                        # Run SonarScanner (uses installed tool or system sonar-scanner)
                        if command -v sonar-scanner >/dev/null 2>&1; then
                            sonar-scanner \
                              -Dsonar.projectKey=flask-2-tier \
                              -Dsonar.projectName="Flask-2-Tier" \
                              -Dsonar.sources=.
                        else
                            echo "sonar-scanner CLI tool found via Jenkins SonarQube Scanner Plugin"
                            ${SONAR_RUNNER_HOME}/bin/sonar-scanner \
                              -Dsonar.projectKey=flask-2-tier \
                              -Dsonar.projectName="Flask-2-Tier" \
                              -Dsonar.sources=.
                        fi
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t flask-app:latest .'
            }
        }

        stage('Run Docker Container') {
            steps {
                echo 'Running Docker container...'
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
}
