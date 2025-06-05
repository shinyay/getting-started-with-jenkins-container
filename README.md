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
├── jenkins/
│   ├── plugins.txt                    # 事前インストールプラグイン一覧
│   └── initial-config/                # 初期設定ファイル
├── scripts/
│   ├── setup.sh                      # 環境セットアップスクリプト
│   ├── start.sh                      # Jenkins起動スクリプト
│   └── stop.sh                       # Jenkins停止スクリプト
└── examples/
    ├── simple-run.sh                 # シンプルな実行例
    ├── with-docker.sh                # Docker-in-Docker例
    └── pipeline-examples/             # パイプライン例
        ├── basic-pipeline.groovy      # 基本パイプライン
        └── docker-pipeline.groovy     # Dockerパイプライン
```

## 🚀 クイックスタート

### 1. 環境セットアップ

```bash
# リポジトリをクローン
git clone <repository-url>
cd getting-started-with-jenkins-container

# セットアップスクリプトを実行
./scripts/setup.sh
```

### 2. Jenkins起動

```bash
# Jenkinsコンテナを起動
./scripts/start.sh
```

### 3. Jenkins設定

1. ブラウザで `http://localhost:8080` にアクセス
2. 起動スクリプトで表示された初期管理者パスワードを入力
3. セットアップウィザードに従って設定を完了

## 📦 含まれるプラグイン

- **基本機能**: Git、GitHub、Pipeline
- **Docker統合**: Docker Workflow、Docker Plugin
- **UI改善**: Blue Ocean、Pipeline Stage View
- **セキュリティ**: Matrix Authorization、Credentials Binding
- **通知**: Email Extension、Mailer
- **その他**: Build Timeout、Timestamper、Workspace Cleanup

## 🛠️ 使用方法

### Docker Composeでの起動

```bash
# バックグラウンドで起動
docker compose up -d

# ログを確認
docker compose logs -f jenkins

# 停止
docker compose down
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

## 📝 パイプライン例

### 基本パイプライン

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

### Dockerパイプライン

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

### よくある問題

1. **ポートが使用中**
   ```bash
   # 使用中のポートを確認
   lsof -i :8080
   ```

2. **権限エラー**
   ```bash
   # Dockerソケットの権限確認
   ls -la /var/run/docker.sock
   ```

3. **メモリ不足**
   ```yaml
   # Java heap サイズを増加
   environment:
     - JAVA_OPTS=-Xmx4g
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

## 🏷️ バージョン情報

- Jenkins: LTS版（推奨）
- Docker: 20.10+
- Docker Compose: 2.0+

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
