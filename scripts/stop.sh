#!/usr/bin/env fish

# Jenkins Container Stop Script for fish shell

echo "🛑 Stopping Jenkins container..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Stop Jenkins container
docker compose down

if test $status -eq 0
    echo "✅ Jenkins container stopped successfully!"
    echo ""
    echo "📋 Note:"
    echo "   💾 Jenkins data is preserved in Docker volume"
    echo "   🔄 You can restart with: ./scripts/start.sh"
    echo "   🗑️  To remove data volume: docker volume rm getting-started-with-jenkins-container_jenkins_home"
else
    echo "❌ Failed to stop Jenkins container"
    echo "Please check: docker compose ps"
    exit 1
end
