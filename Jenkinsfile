pipeline {
    agent { label  "vinod" }

    environment {
        IMAGE_NAME = "angular-ui-app"
        CONTAINER_NAME = "angular-ui-container"
        REPO_URL = "https://github.com/ashsih-raj-devops/angular-UI.git"
        APP_PORT = "80"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git credentialsId: 'github-creds', url: "${REPO_URL}", branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $IMAGE_NAME .'
                }
            }
        }

        stage('Stop and Remove Old Container') {
            steps {
                script {
                    sh """
                        docker stop $CONTAINER_NAME || true
                        docker rm $CONTAINER_NAME || true
                    """
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    sh 'docker run -d -p $APP_PORT:80 --name $CONTAINER_NAME $IMAGE_NAME'
                }
            }
        }
    }

    post {
        success {
            echo 'Success!'
        }
        failure {
            echo 'Failed!'
        }
    }
}
