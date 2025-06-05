#!/usr/bin/env fish

# Jenkins CLI Script for fish shell

set JENKINS_URL "http://localhost:8080"
set JENKINS_CONTAINER "jenkins-container"

# Check if Jenkins container is running
if not docker ps --filter "name=$JENKINS_CONTAINER" --filter "status=running" --quiet
    echo "❌ Error: Jenkins container is not running"
    echo "Please start Jenkins first: ./scripts/start.sh"
    exit 1
end

function jenkins_cli
    # Execute Jenkins CLI inside the container
    docker exec $JENKINS_CONTAINER java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 $argv
end

if test (count $argv) -eq 0
    echo "🔧 Jenkins CLI Helper Script"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Usage: $argv[0] <command> [options]"
    echo ""
    echo "Available commands:"
    echo "  list                    - List all jobs"
    echo "  build <job-name>        - Build a job"
    echo "  build-wait <job-name>   - Build a job and wait for completion"
    echo "  status <job-name>       - Get job status"
    echo "  console <job-name> <#>  - Get console output for build #"
    echo "  help                    - Show Jenkins CLI help"
    echo ""
    echo "Examples:"
    echo "  $argv[0] list"
    echo "  $argv[0] build hello-world-job"
    echo "  $argv[0] build-wait hello-world-job"
    echo "  $argv[0] console hello-world-job 1"
    exit 0
end

switch $argv[1]
case "list"
    echo "📋 Listing all Jenkins jobs..."
    jenkins_cli list-jobs
case "build"
    if test (count $argv) -lt 2
        echo "❌ Error: Job name required"
        echo "Usage: $argv[0] build <job-name>"
        exit 1
    end
    echo "🚀 Starting build for job: $argv[2]"
    jenkins_cli build $argv[2]
case "build-wait"
    if test (count $argv) -lt 2
        echo "❌ Error: Job name required"
        echo "Usage: $argv[0] build-wait <job-name>"
        exit 1
    end
    echo "🚀 Starting build for job: $argv[2] (waiting for completion...)"
    jenkins_cli build $argv[2] -s -v
case "status"
    if test (count $argv) -lt 2
        echo "❌ Error: Job name required"
        echo "Usage: $argv[0] status <job-name>"
        exit 1
    end
    echo "📊 Getting status for job: $argv[2]"
    jenkins_cli get-job $argv[2]
case "console"
    if test (count $argv) -lt 3
        echo "❌ Error: Job name and build number required"
        echo "Usage: $argv[0] console <job-name> <build-number>"
        exit 1
    end
    echo "📝 Getting console output for $argv[2] build #$argv[3]"
    jenkins_cli console $argv[2] $argv[3]
case "help"
    echo "🔧 Jenkins CLI Help"
    jenkins_cli help
case "*"
    echo "❌ Unknown command: $argv[1]"
    echo "Run '$argv[0]' without arguments to see available commands"
    exit 1
end
