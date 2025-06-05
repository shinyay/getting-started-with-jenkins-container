#!/usr/bin/env fish

echo "🔧 Jenkins CLI Download Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Remove existing broken file
rm -f jenkins-cli.jar

echo "📥 Downloading Jenkins CLI jar file..."

# Try multiple download methods
if curl --version >/dev/null 2>&1
    echo "   Using curl..."
    curl -L -o jenkins-cli.jar https://get.jenkins.io/war-stable/latest/jenkins-cli.jar
    if test $status -eq 0; and test -f jenkins-cli.jar; and test (stat -c%s jenkins-cli.jar) -gt 1000
        echo "✅ Downloaded with curl successfully"
    else
        echo "❌ curl download failed"
    end
else if wget --version >/dev/null 2>&1
    echo "   Using wget..."
    wget -O jenkins-cli.jar https://get.jenkins.io/war-stable/latest/jenkins-cli.jar
    if test $status -eq 0; and test -f jenkins-cli.jar; and test (stat -c%s jenkins-cli.jar) -gt 1000
        echo "✅ Downloaded with wget successfully"
    else
        echo "❌ wget download failed"
    end
else
    echo "❌ Neither curl nor wget available"
    exit 1
end

# Verify the downloaded file
if test -f jenkins-cli.jar
    set filesize (stat -c%s jenkins-cli.jar)
    echo "📊 File size: $filesize bytes"
    
    if test $filesize -gt 1000
        echo "✅ Jenkins CLI jar downloaded successfully!"
        echo "   File: jenkins-cli.jar"
        echo "   Size: $filesize bytes"
        
        # Test if it's a valid jar file
        if java -jar jenkins-cli.jar --version >/dev/null 2>&1
            echo "✅ JAR file is valid and executable"
        else
            echo "⚠️  JAR file may not be valid, but downloaded"
        end
    else
        echo "❌ Downloaded file is too small (likely an error page)"
        echo "   Removing invalid file..."
        rm -f jenkins-cli.jar
        exit 1
    end
else
    echo "❌ Failed to download jenkins-cli.jar"
    exit 1
end
