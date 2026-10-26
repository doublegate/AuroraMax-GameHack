#!/usr/bin/env bash
# AuroraMax GameHack First Boot Setup
# /usr/bin/auroramax-firstboot.sh
#
# This script runs on first boot to complete system setup,
# install initial Flatpaks, and configure user environment.

set -euo pipefail

FIRSTBOOT_DONE="/var/lib/auroramax/.firstboot-done"
LOG_FILE="/var/log/auroramax-firstboot.log"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Check if first boot has already been completed
if [ -f "$FIRSTBOOT_DONE" ]; then
    log "First boot setup already completed. Exiting."
    exit 0
fi

log "Starting AuroraMax GameHack first boot setup..."

# Create necessary directories
mkdir -p /var/lib/auroramax
mkdir -p /usr/local/share/auroramax/{themes,wallpapers}

# Ensure Flathub is configured
log "Configuring Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --system

# Install essential Flatpaks based on variant
VARIANT=$(grep "VARIANT=" /etc/auroramax-release 2>/dev/null | cut -d= -f2 || echo "base")
log "Detected variant: $VARIANT"

# Base Flatpaks for all variants
BASE_FLATPAKS=(
    "org.mozilla.firefox"
    "org.kde.ark"
    "org.kde.okular"
)

log "Installing base Flatpaks..."
for flatpak in "${BASE_FLATPAKS[@]}"; do
    log "Installing $flatpak..."
    flatpak install -y --noninteractive flathub "$flatpak" || log "Failed to install $flatpak"
done

# Variant-specific Flatpaks
case "$VARIANT" in
    gaming|gamehack)
        log "Installing gaming-specific Flatpaks..."
        GAMING_FLATPAKS=(
            "com.discordapp.Discord"
            "com.heroicgameslauncher.hgl"
            "net.lutris.Lutris"
            "org.libretro.RetroArch"
            "com.obsproject.Studio"
        )
        for flatpak in "${GAMING_FLATPAKS[@]}"; do
            flatpak install -y --noninteractive flathub "$flatpak" || log "Failed to install $flatpak"
        done
        ;;
    dev*)
        log "Installing development-specific Flatpaks..."
        DEV_FLATPAKS=(
            "com.visualstudio.code"
            "com.getpostman.Postman"
            "org.DBeaver.DBeaverCommunity"
        )
        for flatpak in "${DEV_FLATPAKS[@]}"; do
            flatpak install -y --noninteractive flathub "$flatpak" || log "Failed to install $flatpak"
        done
        ;;
esac

# Update font cache
log "Updating font cache..."
fc-cache -f

# Update desktop database
log "Updating desktop database..."
update-desktop-database

# Configure default ZRAM if not already set
if [ ! -f /etc/systemd/zram-generator.conf ]; then
    log "ZRAM configuration already exists"
else
    log "Configuring ZRAM..."
    systemctl enable --now systemd-zram-setup@zram0.service
fi

# Set up MangoHud default config if not exists
MANGOHUD_CONFIG_DIR="/usr/share/MangoHud"
if [ -d "$MANGOHUD_CONFIG_DIR" ] && [ ! -f "$MANGOHUD_CONFIG_DIR/MangoHud.conf" ]; then
    log "Setting up default MangoHud configuration..."
    cat > "$MANGOHUD_CONFIG_DIR/MangoHud.conf" << EOF
# AuroraMax GameHack default MangoHud configuration
toggle_hud=F12
toggle_fps_limit=F1

legacy_layout=false
gpu_stats
gpu_temp
gpu_power
cpu_stats
cpu_temp
cpu_power
vram
ram
fps
frametime
frame_timing
engine_version
vulkan_driver
gamemode
EOF
fi

# Create welcome message
if [ ! -f /etc/motd.d/10-auroramax ]; then
    log "Creating welcome message..."
    mkdir -p /etc/motd.d
    cat > /etc/motd.d/10-auroramax << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║             Welcome to AuroraMax GameHack!                    ║
║                                                               ║
║  • Run 'just' to see available system commands               ║
║  • Run 'just update' to update your system                   ║
║  • Run 'just help' for documentation                         ║
║                                                               ║
║  Discord: https://discord.gg/auroramax                       ║
║  GitHub:  https://github.com/doublegate/auroramax-gamehack   ║
╚═══════════════════════════════════════════════════════════════╝
EOF
fi

# Mark first boot as complete
touch "$FIRSTBOOT_DONE"
log "First boot setup completed successfully!"

# Offer to run variant-specific setup
if [ "$VARIANT" = "gaming" ] || [ "$VARIANT" = "gamehack" ]; then
    log "Gaming variant detected. Run 'just install-emudeck' to set up emulation."
fi

exit 0
