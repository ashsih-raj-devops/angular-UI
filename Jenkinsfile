pipeline {
    agent any

    environment {
        IMAGE_NAME = "angular-ui-app"
        CONTAINER_NAME = "angular-ui-container"
        REPO_URL = "https://github.com/data-on-disk/dod-main-ui.git"
        EMAIL_RECIPIENTS = "ashishrajtkd123@gmail.com"
        EMAIL_SENDER = "ashishrajdevops@gmail.com"
        PROJECT_NAME = " Main UI - DEV"
        NGINX_VM = "ashis@12.35.35.32"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git credentialsId: 'credentials-id', url: "${REPO_URL}", branch: 'preprod'
            }
        }

        stage('Clean Previous Docker') {
            steps {
                sh '''
                docker stop $CONTAINER_NAME || true
                docker rm $CONTAINER_NAME || true
                docker rmi $IMAGE_NAME || true
                '''
            }
        }

        stage('Build Angular Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Extract Angular Build Output') {
            steps {
                sh '''
                rm -rf angular-dist
                container_id=$(docker create $IMAGE_NAME)
                docker cp $container_id:/app/dist/main-site/browser ./angular-dist
                docker rm $container_id
                '''
            }
        }

        stage('Backup Current Angular App on NGINX VM') {
            steps {
                sh '''
                ssh $NGINX_VM '
                    sudo rm -rf /var/www/angular-app-backup;
                    sudo cp -r /var/www/angular-app /var/www/angular-app-backup || true
                '
                '''
            }
        }

        stage('Copy Build Output to NGINX VM') {
            steps {
                sh '''
                scp -r ./angular-dist/* $NGINX_VM:/var/www/angular-app/
                '''
            }
        }

        stage('Restart NGINX Server') {
            steps {
                sh '''
                ssh $NGINX_VM 'sudo systemctl restart nginx'
                '''
            }
        }
    }

    post {
        success {
            script {
                emailext(
                    attachLog: true,
                    subject: "[SUCCESS] Build #${env.BUILD_NUMBER} - ${PROJECT_NAME}",
                    from: "${EMAIL_SENDER}",
                    to: "${EMAIL_RECIPIENTS}",
                    mimeType: 'text/html',
                    body: """
                    <html>
                        <body>
                            <h2 style="color: #28a745;">Build Successful</h2>
                            <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                            <p><strong>App URL:</strong> <a href="http://12.35.35.32">http://12.35.35.32</a></p>
                        </body>
                    </html>
                    """
                )
            }
        }

        failure {
            script {
                // Restore backup
                sh '''
                ssh $NGINX_VM '
                    sudo rm -rf /var/www/angular-app;
                    sudo cp -r /var/www/angular-app-backup /var/www/angular-app;
                    sudo systemctl restart nginx
                '
                '''

                emailext(
                    attachLog: true,
                    subject: "[FAILURE] Build #${env.BUILD_NUMBER} - ${PROJECT_NAME}",
                    from: "${EMAIL_SENDER}",
                    to: "${EMAIL_RECIPIENTS}",
                    mimeType: 'text/html',
                    body: """
                    <html>
                        <body>
                            <h2 style="color: #dc3545;">Build Failed — Rolled Back</h2>
                            <p><strong>Backup was restored.</strong></p>
                            <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                        </body>
                    </html>
                    """
                )
            }
        }
    }
}
