# =============================================================================
# /etc/wireplumber/main.lua.d/51-auroramax.lua
#
# WirePlumber configuration for AuroraMax GameHack
# =============================================================================

-- Set default audio properties for gaming
alsa_monitor.rules = {
    {
        matches = {{{ "node.name", "matches", "alsa_output.*" }}},
        apply_properties = {
            ["api.alsa.period-size"]   = 256,
            ["api.alsa.headroom"]      = 1024,
            ["session.suspend-timeout-seconds"] = 0,  -- Never suspend
        },
    },
}

-- Disable audio device suspend for lower latency
default_policy.suspend = false

-- Priority for game audio
default_policy.policy = {
    ["move"] = true,
    ["follow"] = true,
    ["audio.priority.driver"] = 2000,
    ["audio.priority.session"] = 1000,
}
