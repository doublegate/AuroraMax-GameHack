#!/bin/bash
set -euxo pipefail

# Create directories for AuroraMax-specific configurations and tools
mkdir -p /opt/auroramax/{bin,lib,share}
mkdir -p /usr/local/share/auroramax/{themes,icons,wallpapers}
mkdir -p /usr/share/auroramax/{docs,scripts}
mkdir -p /usr/share/MangoHud
mkdir -p /var/lib/auroramax

# Set proper permissions for justfiles and AuroraMax scripts if they exist
if [ -d /usr/share/justfiles ]; then
    chmod -R 755 /usr/share/justfiles || true
fi

if ls /usr/bin/auroramax-*.sh 1> /dev/null 2>&1; then
    chmod 755 /usr/bin/auroramax-*.sh || true
fi

# Clean up package cache and temporary files
rpm-ostree cleanup -m || true
rm -rf /tmp/* /var/tmp/* || true
find /usr -name "*.pyc" -delete || true

# Create release information file
cat > /etc/auroramax-release << 'EOF'
NAME="AuroraMax GameHack"
VERSION="1.0"
VARIANT="init-minimal"
PRETTY_NAME="AuroraMax GameHack 1.0 (Init-Minimal)"
HOME_URL="https://github.com/doublegate/auroramax-gamehack"
EOF

echo "AuroraMax GameHack Init-Minimal build completed!"
