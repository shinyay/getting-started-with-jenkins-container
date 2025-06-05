#!/usr/bin/env fish

echo "🐳 Jenkins with Docker-in-Docker Example"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This example shows how to run Jenkins with Docker capabilities."
echo "⚠️  Note: This requires Docker socket access for Docker-in-Docker functionality."
echo ""

# Docker-in-DockerでJenkinsコンテナを起動
echo "📦 Starting Jenkins container with Docker capabilities..."
docker run -d \
  --name jenkins-docker \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_docker_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -u root \
  jenkins/jenkins:lts

if test $status -eq 0
    echo "✅ Jenkins container with Docker started successfully!"
    echo ""
    echo "📋 Container Information:"
    echo "   🆔 Container Name: jenkins-docker"
    echo "   🌐 Web Interface: http://localhost:8080"
    echo "   🔧 Agent Port: 50000"
    echo "   💾 Data Volume: jenkins_docker_home"
    echo "   🐳 Docker Socket: Mounted from host"
    echo ""

    echo "⏳ Waiting for Jenkins to start..."
    sleep 10

    echo "🔑 Initial Admin Password:"
    docker exec jenkins-docker cat /var/jenkins_home/secrets/initialAdminPassword

    echo ""
    echo "🐳 Testing Docker availability inside Jenkins..."
    docker exec jenkins-docker docker --version

    echo ""
    echo "💡 What you can do with this setup:"
    echo "   • Build Docker images in Jenkins pipelines"
    echo "   • Run Docker containers as build steps"
    echo "   • Use Docker agents for Jenkins jobs"
    echo "   • Implement CI/CD pipelines with containerized builds"
    echo ""
    echo "📝 Example Pipeline Script:"
    echo "   pipeline {"
    echo "     agent any"
    echo "     stages {"
    echo "       stage('Build') {"
    echo "         steps {"
    echo "           script {"
    echo "             docker.build('my-app:latest')"
    echo "           }"
    echo "         }"
    echo "       }"
    echo "     }"
    echo "   }"
    echo ""
    echo "💡 Management Commands:"
    echo "   • View logs: docker logs -f jenkins-docker"
    echo "   • Stop container: docker stop jenkins-docker"
    echo "   • Remove container: docker rm jenkins-docker"
    echo "   • Remove volume: docker volume rm jenkins_docker_home"

else
    echo "❌ Failed to start Jenkins container!"
end
