# =============================================================================
# /usr/bin/auroramax-performance.sh
#
# Performance optimization script run at boot
# =============================================================================

#!/bin/bash
# AuroraMax GameHack Performance Optimization Script

set -euo pipefail

# Disable watchdogs if not already done via kernel parameter
echo 0 > /proc/sys/kernel/nmi_watchdog 2>/dev/null || true
echo 0 > /proc/sys/kernel/watchdog 2>/dev/null || true

# Set up ZRAM if not already configured
if [ ! -e /dev/zram0 ]; then
    modprobe zram
    echo lz4 > /sys/block/zram0/comp_algorithm 2>/dev/null || true
    echo 4G > /sys/block/zram0/disksize
    mkswap /dev/zram0
    swapon -p 100 /dev/zram0
fi

# Optimize transparent hugepages
echo never > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true
echo never > /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null || true

# Set CPU governor to schedutil if not already set
for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$gov" ] && echo schedutil > "$gov" 2>/dev/null || true
done

# Enable MGLRU if available
if [ -f /sys/kernel/mm/lru_gen/enabled ]; then
    echo 1 > /sys/kernel/mm/lru_gen/enabled
fi

# Set I/O scheduler for all block devices
for dev in /sys/block/*/queue/scheduler; do
    if [ -f "$dev" ]; then
        # Detect device type and set appropriate scheduler
        device=$(echo "$dev" | cut -d'/' -f4)
        rotational=$(cat "/sys/block/$device/queue/rotational" 2>/dev/null || echo "1")

        if [[ "$device" == nvme* ]]; then
            echo none > "$dev" 2>/dev/null || true
        elif [ "$rotational" = "0" ]; then
            echo kyber > "$dev" 2>/dev/null || echo mq-deadline > "$dev" 2>/dev/null || true
        else
            echo bfq > "$dev" 2>/dev/null || true
        fi
    fi
done

# Set network optimizations
for txq in /sys/class/net/*/tx_queue_len; do
    [ -f "$txq" ] && echo 5000 > "$txq" 2>/dev/null || true
done

# Disable CPU exploit mitigations if configured (via kernel parameter)
# This is commented out by default for security
# echo 0 > /sys/kernel/debug/x86/ibrs_enabled 2>/dev/null || true
# echo 0 > /sys/kernel/debug/x86/ibpb_enabled 2>/dev/null || true

exit 0
