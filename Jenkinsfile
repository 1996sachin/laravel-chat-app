pipeline {
    agent any

    environment {
        DEPLOY_DIR = "/var/www/laravel-chat-app"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/1996sachin/laravel-chat-app.git',
                    credentialsId: 'github-pat'
            }
        }

        stage('Install PHP Dependencies (Docker)') {
            steps {
                sh '''
                docker run --rm -v $(pwd):/app -w /app php:8.1-cli bash -c "
                  apt update &&
                  apt install -y unzip git zip &&
                  curl -sS https://getcomposer.org/installer | php &&
                  php composer.phar install --no-interaction --prefer-dist --optimize-autoloader
                "
                '''
            }
        }

        stage('Install Node Dependencies') {
            steps {
                sh '''
                docker run --rm -v $(pwd):/app -w /app node:18 bash -c "
                npm install
               "
          '''
            }
        }

        stage('Build Assets') {
            steps {
                 sh '''
                 docker run --rm -v $(pwd):/app -w /app node:18 bash -c "
                 npm run build
              "
   '''
            }
        }

        stage('Set Permissions') {
            steps {
                sh '''
                sudo chown -R www-data:www-data .
                sudo chmod -R 755 .
                chmod -R 775 storage bootstrap/cache
                chown -R www-data:www-data storage bootstrap/cache
                '''
            }
        }

        stage('Run Migrations') {
            steps {
                sh 'php artisan migrate --force'
            }
        }

        stage('Clear and Cache Configs') {
            steps {
                sh '''
                php artisan config:clear
                php artisan config:cache
                php artisan route:cache
                php artisan view:cache
                '''
            }
        }

        stage('Restart Services') {
            steps {
                sh 'sudo systemctl restart php8.3-fpm nginx'
            }
        }
    }

    post {
        failure {
            echo '❌ Build failed. Please check the logs.'
        }
        success {
            echo '✅ Deployment successful!'
        }
    }
}
