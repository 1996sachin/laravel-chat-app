pipeline {
    agent any

    environment {
        APP_DIR = "/var/www/html"
    }

    stages {
        stage('Fix Workspace Permissions') {
            steps {
                // Ensure Jenkins can overwrite files before
                sh 'sudo chown -R $USER:$USER $PWD || true'
                sh 'sudo chmod -R u+rwX $PWD || true'
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/1996sachin/laravel-chat-app.git',
                    credentialsId: 'github-pat'
            }
        }

        stage('Prepare .env') {
            steps {
                sh '''
                if [ ! -f .env ]; then
                  cp .env.example .env
                fi
                sed -i 's/DB_DATABASE=.*/DB_DATABASE=chatapp/' .env
                sed -i 's/DB_PASSWORD=.*/DB_PASSWORD=Bipinsingh1/' .env
                sed -i 's/DB_HOST=.*/DB_HOST=db/' .env
                '''
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
                // Ensure Jenkins can overwrite files before checkout
                sh 'sudo chown -R $USER:$USER $PWD || true'
                sh 'sudo chmod -R u+rwX $PWD || true'
            }
        }

        stage('Cleanup Docker Containers') {
            steps {
                 // Remove any existing containers with conflicting names
                sh 'docker rm -f redis || true'
                sh 'docker rm -f mysql || true'
            }
        }

        stage('Start Services') {
            steps {
                // Start MySQL and Redis containers in detached mode
                sh 'docker compose up -d db redis'
                // Wait for MySQL to be ready (simple wait, adjust as needed)
                sh 'docker compose exec db bash -c "until mysqladmin ping -h db --silent; do sleep 1; done"'
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