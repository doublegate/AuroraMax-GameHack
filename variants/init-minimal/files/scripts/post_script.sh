#!/bin/bash
set -euxo pipefail

# Create directories for AuroraMax-specific configurations and tools
mkdir -p /opt/auroramax/{bin,lib,share}
mkdir -p /usr/local/share/auroramax/{themes,icons,wallpapers}
mkdir -p /usr/share/auroramax/{docs,scripts}
mkdir -p /usr/share/MangoHud
mkdir -p /var/lib/auroramax

# Install essential Python packages for the base system
pip3 install --no-cache-dir \
    wheel \
    setuptools \
    pip-autoremove \
    virtualenv \
    pipx

# Enable ZRAM service if the configuration file exists
if [ -f /etc/systemd/zram-generator.conf ]; then
    systemctl enable systemd-zram-setup@zram0.service
fi

# Update font cache
fc-cache -f

# Update man database
mandb

# Update mlocate database for file searching
updatedb

# Set proper permissions for justfiles and AuroraMax scripts
chmod 755 /usr/share/justfiles
chmod 755 /usr/bin/auroramax-*.sh

# Configure VS Code as the default editor if installed
if [ -f /usr/bin/code ]; then
    alternatives --install /usr/bin/editor editor /usr/bin/code 50
fi

# Clean up package cache and temporary files
dnf clean all
rm -rf /tmp/* /var/tmp/*
find /usr -name "*.pyc" -delete
echo "AuroraMax GameHack Init-Minimal build completed!"
