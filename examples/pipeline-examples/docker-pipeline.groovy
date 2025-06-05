// Docker Pipeline Example
// このパイプラインはDockerを使用したCI/CDプロセスの例です

pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'hello-world-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
        DOCKER_REGISTRY = 'localhost:5000'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out source code...'
                // 実際のプロジェクトではgitリポジトリからチェックアウト
                echo 'Source code ready for build'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    // 簡単なDockerfileを動的に作成
                    writeFile file: 'Dockerfile.temp', text: '''
FROM alpine:latest
RUN echo "Hello from Jenkins Docker Pipeline!" > /hello.txt
CMD ["cat", "/hello.txt"]
'''
                    // Dockerイメージをビルド
                    sh "docker build -f Dockerfile.temp -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    sh "docker build -f Dockerfile.temp -t ${DOCKER_IMAGE}:latest ."
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                echo '🧪 Testing Docker image...'
                script {
                    // イメージが正しく動作するかテスト
                    sh "docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG}"

                    // イメージの詳細情報を表示
                    sh "docker images ${DOCKER_IMAGE}"
                    sh "docker inspect ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('Security Scan') {
            steps {
                echo '🔍 Performing security scan...'
                script {
                    // Dockerイメージの脆弱性スキャン（例）
                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v \$(pwd):/tmp/.trivy-cache aquasec/trivy image ${DOCKER_IMAGE}:${DOCKER_TAG} || echo 'Security scan completed with warnings'"
                }
            }
        }

        stage('Push to Registry') {
            when {
                branch 'main'
            }
            steps {
                echo '📤 Pushing to Docker registry...'
                script {
                    // 本番環境では実際のレジストリにプッシュ
                    echo "Would push ${DOCKER_IMAGE}:${DOCKER_TAG} to ${DOCKER_REGISTRY}"
                    echo "Simulating registry push..."

                    // タグ付け（例）
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker tag ${DOCKER_IMAGE}:latest ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest"

                    // プッシュ（コメントアウト - 実際のレジストリが必要）
                    // sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                    // sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo '🚀 Deploying application...'
                script {
                    // デプロイメントのシミュレーション
                    echo "Deploying ${DOCKER_IMAGE}:${DOCKER_TAG} to production..."

                    // コンテナの実行例
                    sh """
                        docker run -d \
                            --name ${DOCKER_IMAGE}-${BUILD_NUMBER} \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """

                    echo "Application deployed successfully!"
                    echo "Container name: ${DOCKER_IMAGE}-${BUILD_NUMBER}"
                }
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning up...'
            script {
                // 一時ファイルの削除
                sh 'rm -f Dockerfile.temp'

                // 古いイメージの削除（オプション）
                sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"

                // テスト用コンテナの停止・削除
                sh "docker stop ${DOCKER_IMAGE}-${BUILD_NUMBER} || true"
                sh "docker rm ${DOCKER_IMAGE}-${BUILD_NUMBER} || true"
            }
        }
        success {
            echo '✅ Docker pipeline completed successfully!'
            echo '🎉 Image built, tested, and deployed!'
        }
        failure {
            echo '❌ Docker pipeline failed!'
            echo '🔍 Please check the logs for details.'
        }
    }
}
