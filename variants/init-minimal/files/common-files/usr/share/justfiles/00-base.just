# AuroraMax GameHack Base System Commands
# /usr/share/justfiles/00-base.just
#
# Core system management commands available in all AuroraMax variants.
# These commands provide essential functionality for updates, maintenance,
# and system configuration.

# Default recipe shows available commands
default:
    @/usr/bin/just --justfile /usr/share/justfiles/justfile --list --unsorted

# Update the entire system (OS, Flatpaks, firmware)
update:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔄 Starting AuroraMax system update..."
    
    # Update the base OS image
    echo "📦 Updating OS image..."
    rpm-ostree upgrade
    
    # Update Flatpaks
    echo "📱 Updating Flatpak applications..."
    flatpak update -y
    
    # Update firmware if fwupd is available
    if command -v fwupdmgr &> /dev/null; then
        echo "🔧 Checking for firmware updates..."
        fwupdmgr refresh --force
        fwupdmgr update
    fi
    
    echo "✅ Update complete! Reboot if the OS was updated."

# Check for updates without applying them
check-updates:
    #!/usr/bin/env bash
    echo "🔍 Checking for available updates..."
    echo
    echo "=== OS Updates ==="
    rpm-ostree upgrade --check
    echo
    echo "=== Flatpak Updates ==="
    flatpak update --appstream
    flatpak remote-ls --updates
    echo
    if command -v fwupdmgr &> /dev/null; then
        echo "=== Firmware Updates ==="
        fwupdmgr get-updates || echo "No firmware updates available"
    fi

# Roll back to the previous OS deployment
rollback:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "⏪ Rolling back to previous OS deployment..."
    rpm-ostree rollback
    echo "✅ Rollback complete. Please reboot to activate."

# Show all OS deployments
deployments:
    rpm-ostree status

# Pin the current deployment to prevent garbage collection
pin DEPLOYMENT="0":
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📌 Pinning deployment {{DEPLOYMENT}}..."
    sudo ostree admin pin {{DEPLOYMENT}}
    echo "✅ Deployment pinned"

# Unpin a deployment
unpin DEPLOYMENT:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📌 Unpinning deployment {{DEPLOYMENT}}..."
    sudo ostree admin pin --unpin {{DEPLOYMENT}}
    echo "✅ Deployment unpinned"

# Clean up old deployments and free disk space
cleanup:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🧹 Cleaning up system..."
    
    # Clean cached OS package metadata without removing pending or rollback deployments
    echo "📦 Cleaning cached OS metadata..."
    rpm-ostree cleanup --base --repomd
    
    # Clean unused Flatpak runtimes
    echo "📱 Removing unused Flatpak runtimes..."
    flatpak uninstall --unused -y
    
    # Clean journal logs
    echo "📝 Vacuuming journal logs..."
    sudo journalctl --vacuum-time=2weeks
    
    # Clean package caches in toolboxes
    echo "🗑️  Cleaning toolbox caches..."
    toolbox list --containers | tail -n +2 | awk '{print $2}' | while read container; do
        echo "  Cleaning $container..."
        toolbox run --container "$container" bash -c "dnf clean all 2>/dev/null || true"
    done
    
    echo "✅ Cleanup complete"

# Show system information
system-info:
    #!/usr/bin/env bash
    echo "🖥️  AuroraMax GameHack System Information"
    echo "========================================"
    if [ -f /etc/auroramax-release ]; then
        cat /etc/auroramax-release
    fi
    echo
    fastfetch || neofetch || (
        echo "OS: $(rpm-ostree status -b | grep Version: | awk '{print $2}')"
        echo "Kernel: $(uname -r)"
        echo "CPU: $(lscpu | grep "Model name" | cut -d: -f2 | xargs)"
        echo "RAM: $(free -h | grep Mem: | awk '{print $2}')"
    )

# Setup Flathub repository if not already configured
setup-flathub:
    #!/usr/bin/env bash
    set -euo pipefail
    if flatpak remotes | grep -q "flathub"; then
        echo "✅ Flathub is already configured"
    else
        echo "📦 Adding Flathub repository..."
        flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        echo "✅ Flathub repository added"
    fi

# Install a Flatpak application
install-flatpak APP:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Installing {{APP}} from Flatpak..."
    flatpak install -y {{APP}}
    echo "✅ {{APP}} installed"

# Remove a Flatpak application
remove-flatpak APP:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🗑️  Removing {{APP}}..."
    flatpak uninstall -y {{APP}}
    echo "✅ {{APP}} removed"

# Create a new toolbox container
create-toolbox NAME IMAGE="fedora-toolbox:latest":
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Creating toolbox {{NAME}} with image {{IMAGE}}..."
    toolbox create --image {{IMAGE}} {{NAME}}
    echo "✅ Toolbox {{NAME}} created"

# Enter a toolbox container
enter-toolbox NAME="":
    #!/usr/bin/env bash
    if [ -z "{{NAME}}" ]; then
        toolbox enter
    else
        toolbox enter {{NAME}}
    fi

# List all toolbox containers
list-toolboxes:
    toolbox list

# Remove a toolbox container
remove-toolbox NAME:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🗑️  Removing toolbox {{NAME}}..."
    toolbox rm {{NAME}}
    echo "✅ Toolbox {{NAME}} removed"

# Check overall system health
check-health:
    #!/usr/bin/env bash
    echo "🏥 System Health Check"
    echo "===================="
    
    # Check failed systemd services
    echo "🔧 Checking for failed services..."
    failed_services=$(systemctl --failed --no-legend | wc -l)
    if [ "$failed_services" -eq 0 ]; then
        echo "✅ No failed services"
    else
        echo "⚠️  $failed_services failed service(s) found:"
        systemctl --failed
    fi
    echo
    
    # Check disk space
    echo "💾 Disk usage:"
    df -h / /boot /boot/efi 2>/dev/null | grep -v tmpfs
    echo
    
    # Check memory
    echo "🧠 Memory usage:"
    free -h
    echo
    
    # Check for broken packages
    echo "📦 Checking package integrity..."
    if rpm-ostree status | grep -q "error"; then
        echo "⚠️  Package errors detected"
    else
        echo "✅ Package integrity OK"
    fi

# Reload system configuration
reload-system-config:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔄 Reloading system configuration..."
    
    # Reload systemd
    sudo systemctl daemon-reload
    
    # Reload sysctl
    sudo sysctl --system
    
    # Reload udev rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    
    echo "✅ System configuration reloaded"

# Show kernel parameters
show-kernel-params:
    #!/usr/bin/env bash
    echo "🐧 Current kernel parameters:"
    echo "============================"
    cat /proc/cmdline | tr ' ' '\n' | sort

# Show active kernel configuration
show-kernel-config:
    #!/usr/bin/env bash
    if [ -f /boot/config-$(uname -r) ]; then
        less /boot/config-$(uname -r)
    else
        echo "❌ Kernel config not found for $(uname -r)"
    fi

# Emergency boot to previous deployment (for critical issues)
emergency-boot-previous:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🚨 Setting up emergency boot to previous deployment..."
    echo "This will configure GRUB to boot the previous deployment ONCE."
    read -p "Are you sure? (yes/NO): " confirm
    if [[ "$confirm" == "yes" ]]; then
        sudo grub2-reboot 1
        echo "✅ Next boot will use previous deployment. Reboot now."
    else
        echo "❌ Cancelled"
    fi

# Verify system integrity
verify-integrity:
    #!/usr/bin/env bash
    echo "🔍 Verifying system integrity..."
    
    # Verify OSTree commit
    echo "📦 Verifying OS image..."
    if rpm-ostree status | grep -q "GPG:"; then
        echo "✅ OS image signature verified"
    else
        echo "⚠️  OS image signature not verified"
    fi
    
    # Check for modified files
    echo "📝 Checking for modified system files..."
    sudo ostree admin status

# Display system logs with priority filtering
logs PRIORITY="3":
    #!/usr/bin/env bash
    echo "📜 System logs (priority ≤ {{PRIORITY}}):"
    journalctl -b -p {{PRIORITY}} --no-pager | tail -50

# Interactive system configuration menu (placeholder for TUI)
configure:
    #!/usr/bin/env bash
    echo "⚙️  AuroraMax Configuration"
    echo "========================"
    echo "This will launch the configuration menu in a future update."
    echo "For now, use specific just commands to configure your system."
    echo
    /usr/bin/just --justfile /usr/share/justfiles/justfile --list --unsorted | grep -E "^(set-|toggle-|enable-|disable-)"
