#!/usr/bin/env fish

# Jenkins Plugin Installation Script for fish shell

if test (count $argv) -eq 0
    echo "🔌 Jenkins Plugin Manager"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Usage: $argv[0] <command> [plugin-name]"
    echo ""
    echo "Available commands:"
    echo "  list                    - List installed plugins"
    echo "  install <plugin-name>   - Install a plugin"
    echo "  restart                 - Restart Jenkins"
    echo ""
    echo "Examples:"
    echo "  $argv[0] list"
    echo "  $argv[0] install workflow-aggregator"
    echo "  $argv[0] restart"
    exit 0
end

switch $argv[1]
case "list"
    echo "📋 Listing installed plugins..."
    docker exec jenkins-container jenkins-plugin-cli --list
case "install"
    if test (count $argv) -lt 2
        echo "❌ Error: Plugin name required"
        echo "Usage: $argv[0] install <plugin-name>"
        exit 1
    end
    echo "🔌 Installing plugin: $argv[2]"
    docker exec jenkins-container jenkins-plugin-cli --plugins $argv[2]
    if test $status -eq 0
        echo "✅ Plugin installed successfully"
        echo "⚠️  You may need to restart Jenkins for the plugin to take effect"
        echo "   Use: $argv[0] restart"
    else
        echo "❌ Failed to install plugin"
    end
case "restart"
    echo "🔄 Restarting Jenkins..."
    docker restart jenkins-container
    if test $status -eq 0
        echo "✅ Jenkins restarted successfully"
        echo "⏳ Please wait a few moments for Jenkins to be ready"
    else
        echo "❌ Failed to restart Jenkins"
    end
case "*"
    echo "❌ Unknown command: $argv[1]"
    echo "Run '$argv[0]' without arguments to see available commands"
    exit 1
end
