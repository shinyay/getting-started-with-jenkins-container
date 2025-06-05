#!/usr/bin/env fish

# Jenkins Pipeline File Runner
# このスクリプトはローカルのパイプラインファイルからジョブを作成・実行します

set JENKINS_URL "http://localhost:8080"
set CLI_JAR "jenkins-cli.jar"

echo "📝 Jenkins Pipeline File Runner"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 使用方法の表示
function show_usage
    echo ""
    echo "📋 Usage:"
    echo "   ./scripts/run-pipeline-file.sh <pipeline-file> [job-name]"
    echo ""
    echo "📝 Examples:"
    echo "   ./scripts/run-pipeline-file.sh examples/pipeline-examples/hello-world-pipeline.groovy"
    echo "   ./scripts/run-pipeline-file.sh examples/pipeline-examples/hello-world-pipeline.groovy my-custom-job"
    echo ""
    echo "💡 This script will:"
    echo "   1. Read the pipeline file"
    echo "   2. Create or update a Jenkins job"
    echo "   3. Execute the job"
end

# 引数チェック
if test (count $argv) -eq 0
    echo "❌ Pipeline file required"
    show_usage
    exit 1
end

set pipeline_file $argv[1]

# ファイル存在チェック
if not test -f $pipeline_file
    echo "❌ Pipeline file not found: $pipeline_file"
    exit 1
end

# ジョブ名の決定
if test (count $argv) -ge 2
    set job_name $argv[2]
else
    # ファイル名からジョブ名を生成
    set job_name (basename $pipeline_file .groovy)
end

echo "📁 Pipeline file: $pipeline_file"
echo "🏷️  Job name: $job_name"

# Jenkins CLI JARファイルの確認
if not test -f $CLI_JAR
    echo "📥 Downloading Jenkins CLI..."
    curl -O "$JENKINS_URL/jnlpJars/jenkins-cli.jar"
    if test $status -ne 0
        echo "❌ Failed to download Jenkins CLI"
        exit 1
    end
end

# パイプラインスクリプトの内容を読み取り
set pipeline_content (cat $pipeline_file)

# 一時的なジョブ設定XMLを作成
set temp_xml "/tmp/jenkins-job-$job_name.xml"
echo "<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin=\"workflow-job@2.40\">
  <actions/>
  <description>Auto-generated from $pipeline_file</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class=\"org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition\" plugin=\"workflow-cps@2.92\">
    <script><![CDATA[$pipeline_content]]></script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>" > $temp_xml

echo "🔧 Creating/updating job..."

# ジョブが存在するかチェック
set job_exists (java -jar $CLI_JAR -s $JENKINS_URL list-jobs | grep -c "^$job_name\$")

if test $job_exists -gt 0
    echo "🔄 Updating existing job: $job_name"
    java -jar $CLI_JAR -s $JENKINS_URL update-job $job_name < $temp_xml
else
    echo "🆕 Creating new job: $job_name"
    java -jar $CLI_JAR -s $JENKINS_URL create-job $job_name < $temp_xml
end

if test $status -eq 0
    echo "✅ Job created/updated successfully!"
    echo "🚀 Starting build..."
    java -jar $CLI_JAR -s $JENKINS_URL build $job_name -s -v
else
    echo "❌ Failed to create/update job"
    exit 1
end

# 一時ファイルをクリーンアップ
rm -f $temp_xml

echo "🎉 Pipeline execution completed!"
