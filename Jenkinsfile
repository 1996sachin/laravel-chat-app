kpipeline {
    agent any

    environment {
        // Use the Jenkins credential with ID 'github-pat'
        GITHUB_TOKEN = credentials('github-pat')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/1996sachin/laravel-chat-app.git',
                    credentialsId: 'github-pat'
            }
        }

        stage('Set Permissions') {
            steps {
                sh '''
                    echo "Fixing workspace permissions..."
                    chown -R jenkins:jenkins $WORKSPACE || true
                    chmod -R u+rwX $WORKSPACE || true
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    echo "Installing dependencies..."
                    npm install
                '''
            }
        }

        stage('Build') {
            steps {
                sh '''
                    echo "Running build..."
                    npm run build || true
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}

