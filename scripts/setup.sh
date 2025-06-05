#!/usr/bin/env fish

# Jenkins Container Setup Script for fish shell

echo "🚀 Setting up Jenkins Container Environment..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if Docker is installed
if not command -v docker >/dev/null 2>&1
    echo "❌ Error: Docker is not installed or not in PATH"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
end

# Check if Docker Compose is installed
if not command -v docker >/dev/null 2>&1; or not docker compose version >/dev/null 2>&1
    echo "❌ Error: Docker Compose is not installed or not working"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
end

echo "✅ Docker and Docker Compose are available"

# Check if we're in the correct directory
if not test -f docker-compose.yml
    echo "❌ Error: docker-compose.yml not found"
    echo "Please run this script from the project root directory"
    exit 1
end

echo "✅ Project structure verified"

# Create necessary directories
mkdir -p jenkins/initial-config
mkdir -p examples/pipeline-examples

echo "✅ Directory structure created"

# Set executable permissions for all scripts
chmod +x scripts/*.sh

echo "✅ Script permissions set"

# Download Jenkins CLI if it doesn't exist
if not test -f jenkins-cli.jar
    echo "📥 Downloading Jenkins CLI..."
    curl -o jenkins-cli.jar https://get.jenkins.io/war-stable/latest/jenkins-cli.jar
    echo "✅ Jenkins CLI downloaded"
else
    echo "✅ Jenkins CLI already exists"
end

echo "🎉 Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Start Jenkins: ./scripts/start.sh"
echo "2. Open browser: http://localhost:8080"
echo "3. Use the initial admin password displayed by start.sh"
echo ""
