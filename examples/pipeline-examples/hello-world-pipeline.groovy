// Hello World Pipeline Example
// このパイプラインはJenkinsの基本的な動作を確認するためのシンプルな例です

pipeline {
    agent any

    stages {
        stage('Hello World') {
            steps {
                echo '🎉 Hello, Jenkins World!'
                echo 'Welcome to your first Jenkins pipeline!'
                echo '=================================='
            }
        }

        stage('Environment Info') {
            steps {
                echo '📋 Environment Information:'
                echo "Build Number: ${BUILD_NUMBER}"
                echo "Job Name: ${JOB_NAME}"
                echo "Workspace: ${WORKSPACE}"
                echo "Build URL: ${BUILD_URL}"
            }
        }

        stage('Basic Commands') {
            steps {
                echo '🔍 Running basic system commands:'
                sh 'echo "Current date and time:"'
                sh 'date'
                sh 'echo "Current working directory:"'
                sh 'pwd'
                sh 'echo "Current user:"'
                sh 'whoami'
                sh 'echo "Available disk space:"'
                sh 'df -h | head -5'
            }
        }

        stage('Success Message') {
            steps {
                echo '✅ Pipeline completed successfully!'
                echo '🎊 Congratulations on your first Jenkins pipeline!'
                echo 'You can now explore more advanced features.'
            }
        }
    }

    post {
        always {
            echo '🧹 This runs regardless of the result.'
        }
        success {
            echo '🎉 Build completed successfully!'
        }
        failure {
            echo '❌ Build failed. Please check the logs.'
        }
    }
}
