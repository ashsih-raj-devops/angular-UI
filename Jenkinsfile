pipeline {
    agent any

    environment {
        REPO_URL = "https://github.com/ashsih-raj-devops/angular-UI.git"
        WEB_VM = "webuser@34.66.161.81"
        NGINX_VM = "nginxuser@34.136.178.145"
        PROJECT_NAME = "DOD Main UI - dev"
        IMAGE_NAME = "dod-ui-app"
        CONTAINER_NAME = "dod-ui-container"
        APP_BUILD_DIR = "/home/webuser/angular-build"
        NGINX_DEPLOY_DIR = "/var/www/angular-app"
        NGINX_BACKUP_DIR = "/var/www/angular-app-backup"
    }

    stages {
        stage('SSH into Web VM & Build Angular') {
            steps {
                sh """
                ssh $WEB_VM << 'EOF'
                    rm -rf $APP_BUILD_DIR || true
                    mkdir -p $APP_BUILD_DIR
                    cd $APP_BUILD_DIR
                    git clone ${REPO_URL} -b dev repo
                    cd repo
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker rmi ${IMAGE_NAME} || true
                    docker build -t ${IMAGE_NAME} .
                    container_id=\$(docker create ${IMAGE_NAME})
                    docker cp \$container_id:/app/dist/main-site/browser ./dist
                    docker rm \$container_id
                EOF
                """
            }
        }

        stage('Backup Existing App on NGINX VM') {
            steps {
                sh """
                ssh $NGINX_VM '
                    sudo rm -rf ${NGINX_BACKUP_DIR};
                    sudo cp -r ${NGINX_DEPLOY_DIR} ${NGINX_BACKUP_DIR} || true
                '
                """
            }
        }

        stage('Copy Build Output to NGINX VM') {
            steps {
                sh """
                scp -r $WEB_VM:$APP_BUILD_DIR/repo/dist/* $NGINX_VM:$NGINX_DEPLOY_DIR/
                """
            }
        }

        stage('Restart NGINX') {
            steps {
                sh """
                ssh $NGINX_VM 'sudo systemctl restart nginx'
                """
            }
        }
    }

    }
}
