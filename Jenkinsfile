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
                script {
                    withSonarQubeEnv(installationName: 'sonar-demo', credentialsId: 'sonar-demo') {
                        def scannerPath = "sonar-scanner"
                        try {
                            def scannerHome = tool 'sonar-demo'
                            scannerPath = "${scannerHome}/bin/sonar-scanner"
                        } catch (Exception e) {
                            echo "Tool 'sonar-demo' not found in Global Tool Configuration, using system sonar-scanner executable."
                        }

                        sh """
                            ${scannerPath} \
                              -Dsonar.projectKey=flask-2-tier \
                              -Dsonar.projectName="Flask-2-Tier" \
                              -Dsonar.sources=.
                        """
                    }
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
