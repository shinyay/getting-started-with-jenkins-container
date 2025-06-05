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
    # Download and execute Jenkins CLI inside the container
    docker exec $JENKINS_CONTAINER bash -c "
        # Download CLI if not exists
        if [ ! -f /tmp/jenkins-cli.jar ]; then
            curl -s -o /tmp/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar
        fi
        # Execute CLI command
        java -jar /tmp/jenkins-cli.jar -s http://localhost:8080 $argv
    "
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
    echo "  auth                    - Show authentication setup help"
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
    set result (jenkins_cli list-jobs 2>&1)
    if test $status -eq 0
        echo $result
    else
        echo "⚠️  CLI access may require authentication setup"
        echo "Result: $result"
        echo ""
        echo "💡 Alternative: Check jobs via Web UI at http://localhost:8080"
    end
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
case "auth"
    echo "🔐 Jenkins CLI Authentication Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "If CLI commands require authentication, you have several options:"
    echo ""
    echo "1. 💻 Use Web UI (Recommended for initial setup):"
    echo "   • Open http://localhost:8080"
    echo "   • Complete initial setup if not done"
    echo "   • Create jobs via the web interface"
    echo ""
    echo "2. 🔑 API Token (For automated access):"
    echo "   • Go to http://localhost:8080/user/admin/configure"
    echo "   • Generate an API token"
    echo "   • Use: jenkins_cli -auth admin:YOUR_TOKEN command"
    echo ""
    echo "3. 🚫 Disable Authentication (Development only):"
    echo "   • Not recommended for production"
    echo "   • Modify Jenkins security settings"
    echo ""
    echo "💡 For this demo environment, the Web UI is the easiest option."
case "*"
    echo "❌ Unknown command: $argv[1]"
    echo "Run '$argv[0]' without arguments to see available commands"
    exit 1
end
