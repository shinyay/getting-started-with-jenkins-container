#!/usr/bin/env fish

# Jenkins REST API Script for fish shell

set JENKINS_URL "http://localhost:8080"

function jenkins_api
    curl -s $argv
end

if test (count $argv) -eq 0
    echo "🌐 Jenkins REST API Helper Script"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Usage: $argv[0] <command> [options]"
    echo ""
    echo "Available commands:"
    echo "  jobs                    - List all jobs"
    echo "  build <job-name>        - Trigger a build"
    echo "  status <job-name>       - Get job status"
    echo "  info                    - Get Jenkins info"
    echo "  health                  - Check Jenkins health"
    echo ""
    echo "Examples:"
    echo "  $argv[0] jobs"
    echo "  $argv[0] build hello-world-job"
    echo "  $argv[0] info"
    exit 0
end

switch $argv[1]
case "jobs"
    echo "📋 Listing all Jenkins jobs via API..."
    jenkins_api "$JENKINS_URL/api/json?pretty=true" | jq '.jobs[] | {name: .name, url: .url}'
case "build"
    if test (count $argv) -lt 2
        echo "❌ Error: Job name required"
        echo "Usage: $argv[0] build <job-name>"
        exit 1
    end
    echo "🚀 Triggering build for job: $argv[2]"
    jenkins_api -X POST "$JENKINS_URL/job/$argv[2]/build"
    if test $status -eq 0
        echo "✅ Build triggered successfully"
    else
        echo "❌ Failed to trigger build"
    end
case "status"
    if test (count $argv) -lt 2
        echo "❌ Error: Job name required"
        echo "Usage: $argv[0] status <job-name>"
        exit 1
    end
    echo "📊 Getting status for job: $argv[2]"
    jenkins_api "$JENKINS_URL/job/$argv[2]/api/json?pretty=true" | jq '{name: .name, buildable: .buildable, lastBuild: .lastBuild.number}'
case "info"
    echo "ℹ️  Getting Jenkins information..."
    jenkins_api "$JENKINS_URL/api/json?pretty=true" | jq '{version: .version, mode: .mode, numExecutors: .numExecutors}'
case "health"
    echo "💚 Checking Jenkins health..."
    if jenkins_api "$JENKINS_URL/login" >/dev/null 2>&1
        echo "✅ Jenkins is healthy and responding"
    else
        echo "❌ Jenkins is not responding"
    end
case "*"
    echo "❌ Unknown command: $argv[1]"
    echo "Run '$argv[0]' without arguments to see available commands"
    exit 1
end
