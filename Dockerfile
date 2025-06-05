# カスタムJenkinsイメージ
# 追加のツールやプラグインを含むJenkinsイメージを作成

FROM jenkins/jenkins:lts

# rootユーザーで実行（Docker-in-Dockerのため）
USER root

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    vim \
    git \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Docker CLIをインストール
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce-cli && rm -rf /var/lib/apt/lists/*

# kubectl をインストール
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Helm をインストール
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list \
    && apt-get update \
    && apt-get install helm \
    && rm -rf /var/lib/apt/lists/*

# Node.js をインストール
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Python とpip をインストール
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# プラグインリストをコピー
COPY jenkins/plugins.txt /usr/share/jenkins/ref/plugins.txt

# プラグインをインストール
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# 初期設定をスキップ
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# jenkinsユーザーをdockerグループに追加
RUN groupadd -g 999 docker && usermod -aG docker jenkins

# jenkinsユーザーに戻る
USER jenkins

# ワークディレクトリを設定
WORKDIR /var/jenkins_home

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/login || exit 1

# ポートを公開
EXPOSE 8080 50000
