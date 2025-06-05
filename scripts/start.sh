#!/usr/bin/env fish

# Jenkins Container Start Script for fish shell

echo "🚀 Starting Jenkins container..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Start Jenkins container
docker compose up -d

if test $status -eq 0
    echo "✅ Jenkins container started successfully!"
    echo ""
    echo "📋 Access Information:"
    echo "   🌐 Jenkins URL: http://localhost:8080"
    echo "   🔧 Management Port: http://localhost:50000"
    echo ""

    # Wait for Jenkins to be ready
    echo "⏳ Waiting for Jenkins to be ready..."
    set max_attempts 30
    set attempt 0

    while test $attempt -lt $max_attempts
        if curl -s -f http://localhost:8080/login >/dev/null 2>&1
            break
        end
        set attempt (math $attempt + 1)
        echo "   Attempt $attempt/$max_attempts..."
        sleep 5
    end

    if test $attempt -eq $max_attempts
        echo "⚠️  Warning: Jenkins may still be starting up"
        echo "   Please wait a few more minutes and check http://localhost:8080"
    else
        echo "✅ Jenkins is ready!"
    end

    echo ""
    echo "🔑 Getting initial admin password..."
    set password (docker exec jenkins-container cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)

    if test -n "$password"
        echo "📝 Initial Admin Password: $password"
        echo ""
        echo "🚀 You can now access Jenkins at: http://localhost:8080"
        echo "   Use the password above for initial setup."
    else
        echo "⚠️  Could not retrieve initial admin password automatically."
        echo "   Run this command manually:"
        echo "   docker exec jenkins-container cat /var/jenkins_home/secrets/initialAdminPassword"
    end
else
    echo "❌ Failed to start Jenkins container"
    echo "Please check Docker logs: docker compose logs jenkins"
    exit 1
end
