# Getting Started with Jenkins Container

🚀 Jenkinsをコンテナで簡単に構築・運用するためのプロジェクトです。

## 📋 概要

このプロジェクトは、Jenkinsをコンテナ環境で効率的に動作させるための包括的なソリューションを提供します。Docker ComposeやKubernetesでの運用に対応し、CI/CDパイプラインの構築を簡単に始められます。

## 🏗️ プロジェクト構成

```
getting-started-with-jenkins-container/
├── README.md                          # このファイル
├── docker-compose.yml                 # Docker Compose設定
├── Dockerfile                         # カスタムJenkinsイメージ
├── jenkins-cli.jar                    # Jenkins CLI JARファイル
├── jenkins/
│   ├── plugins.txt                    # 事前インストールプラグイン一覧
│   └── initial-config/                # 初期設定ファイル
├── scripts/
│   ├── setup.sh                      # 環境セットアップスクリプト
│   ├── start.sh                      # Jenkins起動スクリプト（fish対応）
│   ├── stop.sh                       # Jenkins停止スクリプト（fish対応）
│   ├── jenkins-cli.sh                # Jenkins CLI操作スクリプト
│   ├── jenkins-api.sh                # Jenkins REST API操作スクリプト
│   ├── install-plugins.sh            # プラグインインストールスクリプト
│   └── run-pipeline-file.sh          # パイプラインファイル実行スクリプト
└── examples/
    ├── simple-run.sh                 # シンプルな実行例
    ├── with-docker.sh                # Docker-in-Docker例
    └── pipeline-examples/             # パイプライン例
        ├── basic-pipeline.groovy      # 基本パイプライン
        ├── docker-pipeline.groovy     # Dockerパイプライン
        └── hello-world-pipeline.groovy # Hello Worldパイプライン
```

### 📁 ディレクトリとファイルの詳細

#### 🐳 コンテナ設定ファイル

**docker-compose.yml**
```yaml
version: '3.8'
services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins-container
    ports:
      - "8080:8080"      # Web UI
      - "50000:50000"    # エージェント接続
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - ./jenkins/plugins.txt:/usr/share/jenkins/ref/plugins.txt
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false
      - JENKINS_OPTS=--httpPort=8080
    restart: unless-stopped
    user: root  # Docker-in-Docker使用時
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/login"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
volumes:
  jenkins_home:
```

#### 🔧 fishシェル対応スクリプト

**scripts/start.sh** - Jenkins起動スクリプト
- Docker Composeでコンテナを起動
- 初期管理者パスワードを自動取得・表示
- コンテナ状態の確認
- fishシェル構文で記述

**scripts/stop.sh** - Jenkins停止スクリプト
- Docker Composeでコンテナを停止
- データボリュームは保持

**scripts/jenkins-cli.sh** - Jenkins CLI操作
- ジョブ一覧表示
- ジョブのビルド実行・待機
- ビルド状況確認
- コンソール出力取得

**scripts/jenkins-api.sh** - REST API操作
- Jenkins REST APIを使用した操作
- HTTPリクエストでのジョブ管理

**scripts/install-plugins.sh** - プラグイン管理
- CLI経由でのプラグインインストール
- Pipeline関連プラグインの一括インストール

## 🚀 クイックスタート

### 1. 環境セットアップ

```bash
# リポジトリをクローン
git clone <repository-url>
cd getting-started-with-jenkins-container

# セットアップスクリプトを実行（fish対応）
./scripts/setup.sh
```

### 2. Jenkins起動

```bash
# Jenkinsコンテナを起動（fish対応）
./scripts/start.sh
```

実行結果例：
```
🚀 Starting Jenkins container...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Jenkins container started successfully!

📋 Access Information:
   🌐 Jenkins URL: http://localhost:8080
   🔧 Management Port: http://localhost:50000

🔑 Getting initial admin password...
📝 Initial Admin Password: a1b2c3d4e5f6g7h8i9j0
```

### 3. Jenkins設定

1. ブラウザで `http://localhost:8080` にアクセス
2. 起動スクリプトで表示された初期管理者パスワードを入力
3. セットアップウィザードに従って設定を完了
4. 「推奨プラグインをインストール」を選択（既に主要プラグインは事前インストール済み）

### 4. Hello Worldパイプラインの作成

1. Jenkins Web UIで「新規ジョブ作成」
2. ジョブ名: `hello-world-job`
3. ジョブタイプ: `パイプライン`を選択
4. Pipeline設定で以下のスクリプトを貼り付け：

```groovy
pipeline {
    agent any
    
    stages {
        stage('Hello World') {
            steps {
                echo '🎉 Hello, Jenkins World!'
                echo 'Welcome to your first Jenkins pipeline!'
            }
        }
        
        stage('Environment Info') {
            steps {
                echo "Build Number: ${BUILD_NUMBER}"
                echo "Job Name: ${JOB_NAME}"
                echo "Workspace: ${WORKSPACE}"
            }
        }
        
        stage('Basic Commands') {
            steps {
                sh 'date'
                sh 'pwd'
                sh 'whoami'
                sh 'df -h | head -5'
            }
        }
    }
    
    post {
        success {
            echo '🎉 Build completed successfully!'
        }
        failure {
            echo '❌ Build failed. Please check the logs.'
        }
    }
}
```

### 5. パイプラインの実行

#### Web UIから実行
1. 作成したジョブページで「ビルド実行」をクリック

#### CLIから実行
```bash
# ジョブ一覧を確認
./scripts/jenkins-cli.sh list

# ジョブをビルド実行
./scripts/jenkins-cli.sh build hello-world-job

# ビルド実行して完了まで待機
./scripts/jenkins-cli.sh build-wait hello-world-job

# ビルド結果のコンソール出力を確認
./scripts/jenkins-cli.sh console hello-world-job 1
```

#### REST APIから実行
```bash
# APIでジョブを実行
./scripts/jenkins-api.sh build hello-world-job

# ジョブ状況を確認
./scripts/jenkins-api.sh status hello-world-job
```

## 📦 含まれるプラグイン

### 必須プラグイン (plugins.txt)
```
ant:latest                          # Apache Antビルドツール
antisamy-markup-formatter:latest    # セキュアなマークアップフォーマッター
build-timeout:latest                # ビルドタイムアウト設定
credentials-binding:latest          # 認証情報のバインディング
timestamper:latest                  # ログにタイムスタンプ追加
ws-cleanup:latest                   # ワークスペースクリーンアップ
git:latest                          # Gitソース管理
github:latest                       # GitHub統合
github-branch-source:latest         # GitHubブランチソース
pipeline-stage-view:latest          # パイプラインステージビュー
pipeline-github-lib:latest          # パイプラインGitHubライブラリ
pipeline-build-step:latest          # パイプラインビルドステップ
docker-workflow:latest              # Dockerワークフロー
docker-plugin:latest                # Dockerプラグイン
blueocean:latest                    # Blue Ocean UI
workflow-aggregator:latest          # パイプライン機能集約パッケージ
ssh-slaves:latest                   # SSH経由のエージェント接続
matrix-auth:latest                  # マトリックス認証
pam-auth:latest                     # PAM認証
ldap:latest                         # LDAP認証
email-ext:latest                    # 拡張メール通知
mailer:latest                       # 基本メール機能
```

### インストール後に利用可能な機能
- **Pipeline**: Groovyスクリプトベースのパイプライン
- **Multibranch Pipeline**: ブランチ別の自動パイプライン
- **Blue Ocean**: モダンなWeb UI
- **Docker統合**: コンテナベースのビルド・デプロイ
- **GitHub統合**: プルリクエスト・Webhook連携

## 🛠️ 使用方法とコマンド例

### Docker Composeでの操作

```bash
# バックグラウンドで起動
docker compose up -d

# ログを確認
docker compose logs -f jenkins

# 停止
docker compose down

# 強制再構築
docker compose build --no-cache
docker compose up -d --force-recreate
```

### fishシェル対応スクリプトの使用

#### Jenkins操作
```bash
# Jenkins起動（初期パスワード自動表示）
./scripts/start.sh

# Jenkins停止
./scripts/stop.sh

# セットアップ
./scripts/setup.sh
```

#### Jenkins CLI操作
```bash
# ジョブ一覧表示
./scripts/jenkins-cli.sh list

# ジョブのビルド実行
./scripts/jenkins-cli.sh build <job-name>

# ビルド実行して完了まで待機
./scripts/jenkins-cli.sh build-wait <job-name>

# ジョブのステータス確認
./scripts/jenkins-cli.sh status <job-name>

# コンソール出力取得
./scripts/jenkins-cli.sh console <job-name> <build-number>
```

#### Jenkins REST API操作
```bash
# APIでジョブ実行
./scripts/jenkins-api.sh build <job-name>

# ジョブ情報取得
./scripts/jenkins-api.sh info <job-name>

# ジョブステータス確認
./scripts/jenkins-api.sh status <job-name>
```

#### プラグイン管理
```bash
# インストール済みプラグイン一覧
./scripts/install-plugins.sh list

# 個別プラグインインストール
./scripts/install-plugins.sh install <plugin-name>

# Pipeline関連プラグイン一括インストール
./scripts/install-plugins.sh pipeline
```

### シンプルなコンテナ実行

```bash
# 基本的な実行
./examples/simple-run.sh

# Docker-in-Dockerで実行
./examples/with-docker.sh
```

### カスタムイメージのビルド

```bash
# カスタムJenkinsイメージをビルド
docker build -t custom-jenkins .

# カスタムイメージでDocker Compose実行
docker compose up -d
```

## 🔧 設定のカスタマイズ

### プラグインの追加

`jenkins/plugins.txt` にプラグイン名を追加：

```text
plugin-name:latest
specific-plugin:1.2.3
```

### 環境変数の設定

`docker-compose.yml` の environment セクションで設定：

```yaml
environment:
  - JAVA_OPTS=-Djenkins.install.runSetupWizard=false -Xmx2g
  - JENKINS_OPTS=--httpPort=8080
```

### ポートの変更

`docker-compose.yml` の ports セクションで変更：

```yaml
ports:
  - "9090:8080"  # Webインターフェース
  - "50001:50000"  # エージェント接続
```

## 📝 パイプライン例とファイル内容

### Hello Worldパイプライン (`examples/pipeline-examples/hello-world-pipeline.groovy`)

```groovy
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
```

### 基本パイプライン (`examples/pipeline-examples/basic-pipeline.groovy`)

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
            }
        }
    }
}
```

### Dockerパイプライン (`examples/pipeline-examples/docker-pipeline.groovy`)

```groovy
pipeline {
    agent any
    stages {
        stage('Build Image') {
            steps {
                script {
                    docker.build("my-app:${BUILD_NUMBER}")
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    docker.image("my-app:${BUILD_NUMBER}").run()
                }
            }
        }
    }
}
```

## 🔐 セキュリティ設定

### Docker-in-Dockerのセキュリティ

```yaml
# より安全な設定例
services:
  jenkins:
    # ...
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro  # 読み取り専用
    user: "1000:999"  # jenkinsユーザーID:dockerグループID
```

### プロキシ設定

```yaml
environment:
  - HTTP_PROXY=http://proxy.company.com:8080
  - HTTPS_PROXY=http://proxy.company.com:8080
  - NO_PROXY=localhost,127.0.0.1
```

## 📊 監視とログ

### ログの確認

```bash
# リアルタイムログ
docker compose logs -f jenkins

# 特定期間のログ
docker compose logs --since="2023-01-01" jenkins
```

### ヘルスチェック

```bash
# コンテナの状態確認
docker compose ps

# ヘルスチェック詳細
docker inspect jenkins-container | grep -A 10 Health
```

## 🗄️ データ管理

### バックアップ

```bash
# データボリュームのバックアップ
docker run --rm \
  -v jenkins_home:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/jenkins-backup-$(date +%Y%m%d).tar.gz /data
```

### リストア

```bash
# バックアップからのリストア
docker run --rm \
  -v jenkins_home:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/jenkins-backup-20231201.tar.gz -C /
```

## 🔄 アップグレード

### Jenkinsのアップグレード

```bash
# 新しいイメージをプル
docker compose pull jenkins

# コンテナを再作成
docker compose up -d --force-recreate jenkins
```

## 🚨 トラブルシューティング

### よくある問題と解決方法

#### 1. パイプラインメニューが表示されない
**問題**: 新規ジョブ作成時に「パイプライン」オプションが見つからない
**解決方法**:
```bash
# コンテナを再構築してプラグインを確実にインストール
./scripts/stop.sh
docker compose build --no-cache
./scripts/start.sh

# または手動でプラグインインストール
./scripts/install-plugins.sh pipeline
```

#### 2. Jenkins CLI認証エラー
**問題**: `jenkins-cli.sh`実行時に認証エラーが発生
**解決方法**:
```bash
# Jenkins設定でセキュリティを確認
# Web UIの「Jenkinsの管理」→「セキュリティの設定」で確認

# または初期設定を無効化（開発環境のみ）
# docker-compose.ymlのJAVA_OPTSに以下を追加:
# -Djenkins.install.runSetupWizard=false
```

#### 3. ポートが使用中
**問題**: ポート8080が既に使用されている
**解決方法**:
```bash
# 使用中のポートを確認
lsof -i :8080

# 別のポートを使用（docker-compose.yml編集）
ports:
  - "9090:8080"  # 9090ポートに変更
```

#### 4. Docker権限エラー
**問題**: Docker-in-Dockerでの権限エラー
**解決方法**:
```bash
# Dockerソケットの権限確認
ls -la /var/run/docker.sock

# dockerグループに追加（ホスト側）
sudo usermod -aG docker $USER

# コンテナ内でrootユーザーを使用（docker-compose.yml）
user: root
```

#### 5. メモリ不足エラー
**問題**: Jenkinsがメモリ不足で動作しない
**解決方法**:
```yaml
# docker-compose.ymlでJavaヒープサイズを増加
environment:
  - JAVA_OPTS=-Xmx4g -Djenkins.install.runSetupWizard=false
```

#### 6. プラグインインストール失敗
**問題**: 自動プラグインインストールが失敗する
**解決方法**:
```bash
# plugins.txtの内容確認
cat jenkins/plugins.txt

# 手動でプラグインディレクトリ確認
docker exec jenkins-container ls -la /var/jenkins_home/plugins/

# コンテナ内でプラグインを手動インストール
docker exec jenkins-container jenkins-plugin-cli --plugins workflow-aggregator
```

### デバッグコマンド

#### コンテナ状況確認
```bash
# コンテナ状況
docker compose ps

# ログ確認
docker compose logs jenkins

# コンテナ内部確認
docker exec -it jenkins-container bash
```

#### Jenkins状況確認
```bash
# Jenkins CLI接続テスト
./scripts/jenkins-cli.sh help

# プラグイン状況確認
./scripts/install-plugins.sh list

# ヘルスチェック
curl -f http://localhost:8080/login
```

## 📚 参考資料

- [Jenkins公式ドキュメント](https://www.jenkins.io/doc/)
- [Jenkins Docker Hub](https://hub.docker.com/r/jenkins/jenkins)
- [Docker Compose公式ドキュメント](https://docs.docker.com/compose/)
- [Jenkins Pipeline構文リファレンス](https://www.jenkins.io/doc/book/pipeline/syntax/)

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/AmazingFeature`)
3. 変更をコミット (`git commit -m 'Add some AmazingFeature'`)
4. ブランチにプッシュ (`git push origin feature/AmazingFeature`)
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。

## 🏷️ バージョン情報と環境構築の流れ

### 検証済み環境
- **Jenkins**: 2.504.2 LTS
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **シェル**: fish (fishシェル対応スクリプト)
- **OS**: Linux (開発・テスト済み)

### 環境構築の実施内容

#### 1. 基盤環境の構築
- ✅ Docker ComposeによるJenkinsコンテナ設定
- ✅ Jenkins LTS 2.504.2イメージの使用
- ✅ Docker-in-Docker対応（/var/run/docker.sock共有）
- ✅ 永続ボリューム設定（jenkins_home）
- ✅ ヘルスチェック機能

#### 2. プラグイン環境の整備
- ✅ 必須プラグインの事前定義（plugins.txt）
- ✅ Pipeline関連プラグイン（workflow-aggregator等）
- ✅ Blue Ocean UI
- ✅ Docker Workflow
- ✅ GitHub統合
- ✅ セキュリティ・認証プラグイン

#### 3. fishシェル対応スクリプトの作成
- ✅ start.sh: Jenkins起動と初期パスワード取得
- ✅ stop.sh: Jenkins停止
- ✅ setup.sh: 環境セットアップ
- ✅ jenkins-cli.sh: CLI操作（list/build/status/console）
- ✅ jenkins-api.sh: REST API操作
- ✅ install-plugins.sh: プラグイン管理

#### 4. サンプルパイプラインの作成
- ✅ hello-world-pipeline.groovy: 基本的なパイプライン例
- ✅ basic-pipeline.groovy: シンプルなCI/CDパイプライン
- ✅ docker-pipeline.groovy: Dockerを使用したパイプライン

#### 5. 動作確認済み機能
- ✅ Jenkinsコンテナの起動・停止
- ✅ Web UI（http://localhost:8080）での管理画面アクセス
- ✅ 初期セットアップウィザードの完了
- ✅ パイプラインプラグインのインストール
- ✅ パイプラインジョブの作成・実行
- ✅ Jenkins CLIでのジョブ操作
- ✅ fishシェルスクリプトの動作

---

**🎉 Happy Building with Jenkins!**

## Features

- feature:1
- feature:2

## Requirement

## Usage

## Installation

## References

## Licence

Released under the [MIT license](https://gist.githubusercontent.com/shinyay/56e54ee4c0e22db8211e05e70a63247e/raw/f3ac65a05ed8c8ea70b653875ccac0c6dbc10ba1/LICENSE)

## Author

- github: <https://github.com/shinyay>
- twitter: <https://twitter.com/yanashin18618>
- mastodon: <https://mastodon.social/@yanashin>
