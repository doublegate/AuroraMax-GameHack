# AuroraMax GameHack Hardware Management Commands
# /usr/share/justfiles/02-hardware.just
#
# Commands for managing hardware settings, drivers, and device configurations.

# Show detailed hardware information
hardware-info:
    #!/usr/bin/env bash
    echo "🖥️  Hardware Information"
    echo "====================="
    echo
    echo "=== CPU ==="
    lscpu | grep -E "(Model name|CPU\(s\)|Thread|Core|Socket|CPU MHz|BogoMIPS)"
    echo
    echo "=== Memory ==="
    free -h
    echo
    echo "=== Graphics ==="
    lspci | grep -E "(VGA|3D|Display)"
    echo
    if command -v glxinfo &>/dev/null; then
        echo "OpenGL: $(glxinfo | grep "OpenGL renderer" | cut -d: -f2)"
    fi
    if command -v vulkaninfo &>/dev/null; then
        echo "Vulkan: $(vulkaninfo 2>/dev/null | grep "deviceName" | head -1 | cut -d= -f2 || echo "N/A")"
    fi
    echo
    echo "=== Storage ==="
    lsblk -d -o NAME,SIZE,TYPE,ROTA,DISC-GRAN,MODEL
    echo
    echo "=== Network ==="
    ip -br link show

# Show GPU information and status
gpu-info:
    #!/usr/bin/env bash
    echo "🎮 GPU Information"
    echo "================="
    echo
    # Basic GPU info
    lspci -k | grep -A 3 -E "(VGA|3D|Display)"
    echo

    # Intel GPU
    if lspci | grep -qi "intel.*graphics"; then
        echo "=== Intel GPU ==="
        if [ -f /sys/class/drm/card0/device/power_dpm_force_performance_level ]; then
            echo "Power profile: $(cat /sys/class/drm/card0/device/power_dpm_force_performance_level 2>/dev/null || echo "N/A")"
        fi
        if command -v intel_gpu_frequency &>/dev/null; then
            intel_gpu_frequency -g 2>/dev/null || echo "Frequency info not available"
        fi
        echo
    fi

    # AMD GPU
    if lspci | grep -qi "amd.*radeon\|amd.*graphics"; then
        echo "=== AMD GPU ==="
        for gpu in /sys/class/drm/card*/device/; do
            if [ -f "$gpu/power_dpm_force_performance_level" ]; then
                echo "Power profile: $(cat "$gpu/power_dpm_force_performance_level" 2>/dev/null)"
                echo "Current frequency: $(cat "$gpu/pp_dpm_sclk" 2>/dev/null | grep '*' || echo "N/A")"
            fi
        done
        echo
    fi

    # NVIDIA GPU
    if lspci | grep -qi nvidia; then
        echo "=== NVIDIA GPU ==="
        if command -v nvidia-smi &>/dev/null; then
            nvidia-smi --query-gpu=name,driver_version,temperature.gpu,power.draw --format=csv,noheader
        else
            echo "Using Nouveau driver (nvidia-smi not available)"
        fi
        echo
    fi

# Configure display settings
configure-display PROFILE="auto":
    #!/usr/bin/env bash
    set -euo pipefail

    case "{{PROFILE}}" in
        auto)
            echo "🖥️  Auto-detecting display configuration..."
            if command -v xrandr &>/dev/null && [ -n "${DISPLAY:-}" ]; then
                xrandr --auto
                echo "✅ Display configuration updated"
            else
                echo "❌ xrandr not available or no display"
            fi
            ;;
        gaming)
            echo "🎮 Applying gaming display profile..."
            echo "This would set optimal refresh rate and disable compositing"
            echo "Feature coming soon!"
            ;;
        *)
            echo "❌ Unknown profile: {{PROFILE}}"
            echo "Available profiles: auto, gaming"
            exit 1
            ;;
    esac

# List input devices
list-input-devices:
    #!/usr/bin/env bash
    echo "🎮 Input Devices"
    echo "==============="
    echo
    echo "=== All Input Devices ==="
    if command -v libinput &>/dev/null; then
        sudo libinput list-devices 2>/dev/null | grep -E "(Device:|Capabilities:)" | sed 'N;s/\n/\t/'
    else
        ls -la /dev/input/by-id/
    fi
    echo
    echo "=== Game Controllers ==="
    if [ -d /dev/input ]; then
        for js in /dev/input/js*; do
            if [ -e "$js" ]; then
                echo "Found: $js"
                udevadm info --query=all --name="$js" 2>/dev/null | grep -E "(ID_VENDOR=|ID_MODEL=)" | sed 's/E: /  /'
            fi
        done
    fi

# Test game controller
test-controller DEVICE="/dev/input/js0":
    #!/usr/bin/env bash
    set -euo pipefail

    if [ ! -e "{{DEVICE}}" ]; then
        echo "❌ Controller device not found: {{DEVICE}}"
        echo "Available devices:"
        ls /dev/input/js* 2>/dev/null || echo "No controllers found"
        exit 1
    fi

    echo "🎮 Testing controller: {{DEVICE}}"
    echo "Press Ctrl+C to exit"
    echo

    if command -v jstest &>/dev/null; then
        jstest "{{DEVICE}}"
    elif command -v evtest &>/dev/null; then
        sudo evtest "{{DEVICE}}"
    else
        echo "❌ No controller test tool available"
        echo "Install with: sudo dnf install joystick-support"
    fi

# Configure controller (basic)
configure-controller ACTION="list":
    #!/usr/bin/env bash

    case "{{ACTION}}" in
        list)
            echo "🎮 Controller Configuration"
            echo "========================"
            if [ -f /proc/bus/input/devices ]; then
                grep -B5 -A5 "js\|Joystick\|Gamepad" /proc/bus/input/devices
            fi
            ;;
        calibrate)
            echo "🎮 Controller calibration"
            echo "Install jstest-gtk for a GUI calibration tool"
            echo "Or use jscal for command-line calibration"
            ;;
        *)
            echo "❌ Unknown action: {{ACTION}}"
            echo "Available actions: list, calibrate"
            ;;
    esac

# Enable/disable Bluetooth
toggle-bluetooth STATE="on":
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "{{STATE}}" != "on" && "{{STATE}}" != "off" ]]; then
        echo "❌ Invalid state: {{STATE}}. Use 'on' or 'off'"
        exit 1
    fi

    echo "📶 Toggling Bluetooth {{STATE}}..."

    if [[ "{{STATE}}" == "on" ]]; then
        sudo systemctl start bluetooth.service
        sudo systemctl enable bluetooth.service
        if command -v bluetoothctl &>/dev/null; then
            bluetoothctl power on
        fi
        echo "✅ Bluetooth enabled"
    else
        if command -v bluetoothctl &>/dev/null; then
            bluetoothctl power off
        fi
        sudo systemctl stop bluetooth.service
        sudo systemctl disable bluetooth.service
        echo "✅ Bluetooth disabled"
    fi

# Show power consumption information
power-info:
    #!/usr/bin/env bash
    echo "⚡ Power Information"
    echo "=================="

    # Battery info
    if [ -d /sys/class/power_supply/BAT0 ]; then
        echo "=== Battery ==="
        echo "Status: $(cat /sys/class/power_supply/BAT0/status 2>/dev/null)"
        echo "Capacity: $(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)%"
        if [ -f /sys/class/power_supply/BAT0/power_now ]; then
            power_now=$(cat /sys/class/power_supply/BAT0/power_now)
            echo "Power draw: $(echo "scale=2; $power_now / 1000000" | bc) W"
        fi
        echo
    fi

    # CPU power info
    if command -v turbostat &>/dev/null; then
        echo "=== CPU Power States (5 second sample) ==="
        sudo turbostat --quiet --Summary --show PkgWatt,CorWatt --interval 5 2>/dev/null | head -20
    elif command -v powertop &>/dev/null; then
        echo "Run 'sudo powertop' for detailed power analysis"
    fi

# Configure power profile
set-power-profile PROFILE="balanced":
    #!/usr/bin/env bash
    set -euo pipefail

    valid_profiles="power-saver balanced performance"
    if [[ ! " $valid_profiles " =~ " {{PROFILE}} " ]]; then
        echo "❌ Invalid profile: {{PROFILE}}"
        echo "Valid options: $valid_profiles"
        exit 1
    fi

    echo "⚡ Setting power profile to {{PROFILE}}..."

    # Try powerprofilesctl first (GNOME Power Profiles Daemon)
    if command -v powerprofilesctl &>/dev/null; then
        powerprofilesctl set {{PROFILE}}
        echo "✅ Power profile set via powerprofilesctl"
    # Try tuned
    elif command -v tuned-adm &>/dev/null; then
        case "{{PROFILE}}" in
            power-saver)
                sudo tuned-adm profile powersave
                ;;
            balanced)
                sudo tuned-adm profile balanced
                ;;
            performance)
                sudo tuned-adm profile latency-performance
                ;;
        esac
        echo "✅ Power profile set via tuned"
    else
        echo "⚠️  No power profile daemon found"
        echo "Falling back to CPU governor adjustment"
        case "{{PROFILE}}" in
            power-saver)
                just set-cpu-governor powersave
                ;;
            balanced)
                just set-cpu-governor schedutil
                ;;
            performance)
                just set-cpu-governor performance
                ;;
        esac
    fi

# Show sensor readings
sensors:
    #!/usr/bin/env bash
    echo "🌡️  System Sensors"
    echo "================"

    if command -v sensors &>/dev/null; then
        sensors
    else
        echo "❌ lm_sensors not installed"
        echo "Install with: sudo dnf install lm_sensors"
        echo "Then run: sudo sensors-detect"
    fi
