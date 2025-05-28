# AuroraMax GameHack Performance Management Commands
# /usr/share/justfiles/01-performance.just
#
# Commands for managing system performance settings including CPU governors,
# kernel parameters, and various performance optimizations.

# Set CPU frequency governor for all cores
set-cpu-governor GOVERNOR="schedutil":
    #!/usr/bin/env bash
    set -euo pipefail
    valid_governors="performance powersave schedutil ondemand conservative"

    if [[ ! " $valid_governors " =~ " {{GOVERNOR}} " ]]; then
        echo "❌ Invalid governor: {{GOVERNOR}}"
        echo "Valid options: $valid_governors"
        exit 1
    fi

    echo "⚡ Setting CPU governor to {{GOVERNOR}}..."

    # Check if we can write to scaling_governor
    if [ ! -w /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        echo "❌ Cannot set CPU governor. Running with sudo..."
        sudo bash -c "for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo {{GOVERNOR}} > \$gov; done"
    else
        for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo {{GOVERNOR}} > "$gov"
        done
    fi

    # Verify the change
    current=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    if [ "$current" = "{{GOVERNOR}}" ]; then
        echo "✅ CPU governor set to {{GOVERNOR}}"
    else
        echo "⚠️  Failed to set governor (current: $current)"
    fi

# Show current CPU governor and frequency info
show-cpu-info:
    #!/usr/bin/env bash
    echo "🖥️  CPU Performance Information"
    echo "=============================="
    echo
    echo "Current Governor:"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo
    echo "Available Governors:"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
    echo
    echo "CPU Frequencies (MHz):"
    grep "cpu MHz" /proc/cpuinfo | sort -u
    echo
    echo "Frequency Limits:"
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        if [ -d "$cpu/cpufreq" ]; then
            cpu_num=$(basename "$cpu")
            min=$(cat "$cpu/cpufreq/scaling_min_freq" 2>/dev/null || echo "N/A")
            max=$(cat "$cpu/cpufreq/scaling_max_freq" 2>/dev/null || echo "N/A")
            cur=$(cat "$cpu/cpufreq/scaling_cur_freq" 2>/dev/null || echo "N/A")
            printf "%-6s Min: %8s kHz, Max: %8s kHz, Current: %8s kHz\n" "$cpu_num:" "$min" "$max" "$cur"
        fi
    done

# Toggle Transparent Huge Pages
toggle-thp STATE="off":
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "{{STATE}}" != "on" && "{{STATE}}" != "off" ]]; then
        echo "❌ Invalid state: {{STATE}}. Use 'on' or 'off'"
        exit 1
    fi

    echo "📄 Toggling Transparent Huge Pages {{STATE}}..."

    current_kargs=$(rpm-ostree kargs)

    if [[ "{{STATE}}" == "off" ]]; then
        if [[ "$current_kargs" != *"transparent_hugepage=never"* ]]; then
            echo "🔧 Adding transparent_hugepage=never to kernel arguments..."
            sudo rpm-ostree kargs --append-if-missing=transparent_hugepage=never
            echo "⚠️  Reboot required to apply changes"
        else
            echo "✅ THP already disabled in kernel arguments"
        fi

        # Try to disable at runtime too
        if [ -w /sys/kernel/mm/transparent_hugepage/enabled ]; then
            echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled >/dev/null
            echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag >/dev/null
            echo "✅ THP disabled at runtime"
        fi
    else
        if [[ "$current_kargs" == *"transparent_hugepage=never"* ]]; then
            echo "🔧 Removing transparent_hugepage=never from kernel arguments..."
            sudo rpm-ostree kargs --delete=transparent_hugepage=never
            echo "⚠️  Reboot required to apply changes"
        else
            echo "✅ THP already enabled in kernel arguments"
        fi

        # Try to enable at runtime
        if [ -w /sys/kernel/mm/transparent_hugepage/enabled ]; then
            echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled >/dev/null
            echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/defrag >/dev/null
            echo "✅ THP enabled at runtime (madvise)"
        fi
    fi

# Toggle CPU mitigations (DANGEROUS - reduces security)
toggle-mitigations STATE="on":
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "{{STATE}}" != "on" && "{{STATE}}" != "off" ]]; then
        echo "❌ Invalid state: {{STATE}}. Use 'on' or 'off'"
        exit 1
    fi

    if [[ "{{STATE}}" == "off" ]]; then
        echo "⚠️  WARNING: Disabling CPU mitigations reduces security!"
        echo "This exposes your system to Spectre, Meltdown, and other vulnerabilities."
        echo "Only proceed if you understand and accept the risks."
        echo
        read -p "Are you SURE you want to disable CPU mitigations? (type 'yes' to confirm): " confirm

        if [[ "$confirm" != "yes" ]]; then
            echo "❌ Cancelled"
            exit 0
        fi
    fi

    current_kargs=$(rpm-ostree kargs)

    if [[ "{{STATE}}" == "off" ]]; then
        if [[ "$current_kargs" != *"mitigations=off"* ]]; then
            echo "🛡️  Disabling CPU mitigations..."
            sudo rpm-ostree kargs --append-if-missing=mitigations=off
            echo "⚠️  Reboot required. Mitigations will be DISABLED after reboot!"
        else
            echo "⚠️  CPU mitigations already disabled"
        fi
    else
        if [[ "$current_kargs" == *"mitigations=off"* ]]; then
            echo "🛡️  Re-enabling CPU mitigations..."
            sudo rpm-ostree kargs --delete=mitigations=off
            echo "✅ Reboot required. Mitigations will be enabled after reboot."
        else
            echo "✅ CPU mitigations already enabled"
        fi
    fi

# Clear shader caches
clear-shader-cache:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🎮 Clearing shader caches..."

    # Mesa shader cache
    if [ -d ~/.cache/mesa_shader_cache ]; then
        rm -rf ~/.cache/mesa_shader_cache/*
        echo "✅ Cleared Mesa shader cache"
    fi

    # AMD
    if [ -d ~/.cache/AMD/VkCache ]; then
        rm -rf ~/.cache/AMD/VkCache/*
        echo "✅ Cleared AMD Vulkan cache"
    fi

    # NVIDIA (if proprietary driver is installed)
    if [ -d ~/.nv/ComputeCache ]; then
        rm -rf ~/.nv/ComputeCache/*
        echo "✅ Cleared NVIDIA compute cache"
    fi

    # Steam shader cache
    if [ -d ~/.local/share/Steam/steamapps/shadercache ]; then
        echo "🎮 Clearing Steam shader cache..."
        rm -rf ~/.local/share/Steam/steamapps/shadercache/*
        echo "✅ Cleared Steam shader cache"
    fi

    # DXVK state cache
    find ~/Games ~/.wine ~/.local/share/lutris -name "*.dxvk-cache" -delete 2>/dev/null || true

    echo "✅ All shader caches cleared"

# Apply gaming performance optimizations
optimize-gaming:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🎮 Applying gaming performance optimizations..."

    # Set CPU to performance mode
    just set-cpu-governor performance

    # Disable mouse acceleration (for FPS games)
    if command -v xinput &>/dev/null; then
        for device in $(xinput list | grep -i mouse | grep -oP 'id=\K\d+'); do
            xinput set-prop "$device" "libinput Accel Profile Enabled" 0 1 2>/dev/null || true
        done
        echo "✅ Disabled mouse acceleration"
    fi

    # Enable GameMode if available
    if command -v gamemoded &>/dev/null; then
        systemctl --user start gamemoded.service 2>/dev/null || true
        echo "✅ GameMode daemon started"
    fi

    # Set I/O scheduler to deadline for lower latency
    for device in /sys/block/*/queue/scheduler; do
        if [ -w "$device" ]; then
            echo mq-deadline | sudo tee "$device" >/dev/null 2>&1 || true
        fi
    done

    echo "✅ Gaming optimizations applied"

# Reset to balanced performance profile
optimize-balanced:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "⚖️  Applying balanced performance profile..."

    # Set CPU to schedutil (balanced)
    just set-cpu-governor schedutil

    # Re-enable mouse acceleration
    if command -v xinput &>/dev/null; then
        for device in $(xinput list | grep -i mouse | grep -oP 'id=\K\d+'); do
            xinput set-prop "$device" "libinput Accel Profile Enabled" 1 0 2>/dev/null || true
        done
    fi

    echo "✅ Balanced profile applied"

# Show current kernel parameters related to performance
show-performance-params:
    #!/usr/bin/env bash
    echo "⚡ Performance-related kernel parameters:"
    echo "======================================="
    echo
    echo "Current kernel command line:"
    cat /proc/cmdline | tr ' ' '\n' | grep -E "(mitigations|transparent_hugepage|preempt|tick|idle|pstate|cpufreq)" | sort
    echo
    echo "THP status:"
    cat /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || echo "Not available"
    echo
    echo "CPU vulnerability mitigations:"
    grep -E "(Vulnerable|Mitigation)" /sys/devices/system/cpu/vulnerabilities/* 2>/dev/null | sed 's/.*vulnerabilities\///' | column -t -s ':' || echo "Not available"

# Enable or disable turbo boost
toggle-turbo STATE="on":
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "{{STATE}}" != "on" && "{{STATE}}" != "off" ]]; then
        echo "❌ Invalid state: {{STATE}}. Use 'on' or 'off'"
        exit 1
    fi

    echo "🚀 Toggling CPU turbo boost {{STATE}}..."

    # Intel
    if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        if [[ "{{STATE}}" == "on" ]]; then
            echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo >/dev/null
        else
            echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo >/dev/null
        fi
        echo "✅ Intel turbo boost {{STATE}}"
    fi

    # AMD
    if [ -f /sys/devices/system/cpu/cpufreq/boost ]; then
        if [[ "{{STATE}}" == "on" ]]; then
            echo 1 | sudo tee /sys/devices/system/cpu/cpufreq/boost >/dev/null
        else
            echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost >/dev/null
        fi
        echo "✅ AMD turbo boost {{STATE}}"
    fi

    # Legacy method
    if [ -f /sys/devices/system/cpu/cpufreq/boost ]; then
        if [[ "{{STATE}}" == "on" ]]; then
            echo 1 | sudo tee /sys/devices/system/cpu/cpufreq/boost >/dev/null
        else
            echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost >/dev/null
        fi
    fi

# Run system benchmark
benchmark TYPE="cpu":
    #!/usr/bin/env bash
    set -euo pipefail

    case "{{TYPE}}" in
        cpu)
            echo "🖥️  Running CPU benchmark..."
            if command -v stress-ng &>/dev/null; then
                stress-ng --cpu $(nproc) --cpu-method all --metrics --timeout 30s
            else
                echo "❌ stress-ng not installed"
                echo "Install it with: sudo dnf install stress-ng"
            fi
            ;;
        memory)
            echo "🧠 Running memory benchmark..."
            if command -v sysbench &>/dev/null; then
                sysbench memory --memory-total-size=4G run
            else
                echo "❌ sysbench not installed"
                echo "Install it with: sudo dnf install sysbench"
            fi
            ;;
        disk)
            echo "💾 Running disk benchmark..."
            echo "Testing sequential write speed..."
            dd if=/dev/zero of=/tmp/test.img bs=1M count=1024 oflag=dsync 2>&1 | grep -E "[0-9.]+ [MG]B/s"
            rm -f /tmp/test.img
            ;;
        *)
            echo "❌ Unknown benchmark type: {{TYPE}}"
            echo "Available types: cpu, memory, disk"
            exit 1
            ;;
    esac
