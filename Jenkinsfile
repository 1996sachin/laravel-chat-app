pipeline {
    agent any

    environment {
        APP_DIR = "/var/www/html"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/1996sachin/laravel-chat-app.git',
                    credentialsId: 'github-pat'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image with PHP + Node
                    sh 'docker build -t laravel-chat-app .'
                }
            }
        }

        stage('Run Composer & Node') {
            steps {
                script {
                    // Run container to install dependencies and build assets
                    sh '''
                    docker run --rm -v $PWD:$APP_DIR -w $APP_DIR laravel-chat-app bash -c "
                        composer install --no-interaction --prefer-dist --optimize-autoloader &&
                        npm install &&
                        npm run build
                    "
                    '''
                }
            }
        }

        stage('Set Permissions') {
            steps {
                sh '''
                docker run --rm -v $PWD:$APP_DIR -w $APP_DIR laravel-chat-app bash -c "
                    chown -R www-data:www-data storage bootstrap/cache
                "
                '''
            }
        }

        stage('Run Migrations') {
            steps {
                sh '''
                docker run --rm -v $PWD:$APP_DIR -w $APP_DIR laravel-chat-app bash -c "
                    php artisan migrate --force
                "
                '''
            }
        }

        stage('Restart Services') {
            steps {
                echo "Service restart logic here (depends on your environment)"
            }
        }
    }

    post {
        success {
            echo '✅ Build and deploy succeeded!'
        }
        failure {
            echo '❌ Build failed. Check the logs.'
        }
    }
}
