#!/usr/bin/env fish

echo "🚀 Simple Jenkins Container Example"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This example shows how to run Jenkins with basic configuration."
echo ""

# シンプルなJenkinsコンテナの起動
echo "📦 Starting Jenkins container with basic settings..."
docker run -d \
  --name jenkins-simple \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_simple_home:/var/jenkins_home \
  jenkins/jenkins:lts

if test $status -eq 0
    echo "✅ Jenkins container started successfully!"
    echo ""
    echo "📋 Container Information:"
    echo "   🆔 Container Name: jenkins-simple"
    echo "   🌐 Web Interface: http://localhost:8080"
    echo "   🔧 Agent Port: 50000"
    echo "   💾 Data Volume: jenkins_simple_home"
    echo ""

    echo "⏳ Waiting for Jenkins to start (this may take a few minutes)..."
    sleep 10

    echo "🔑 Initial Admin Password:"
    docker exec jenkins-simple cat /var/jenkins_home/secrets/initialAdminPassword

    echo ""
    echo "💡 Management Commands:"
    echo "   • View logs: docker logs -f jenkins-simple"
    echo "   • Stop container: docker stop jenkins-simple"
    echo "   • Remove container: docker rm jenkins-simple"
    echo "   • Remove volume: docker volume rm jenkins_simple_home"

else
    echo "❌ Failed to start Jenkins container!"
end
