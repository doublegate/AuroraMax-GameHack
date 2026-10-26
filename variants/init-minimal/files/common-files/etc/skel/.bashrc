#!/bin/bash
# AuroraMax GameHack Complete .bashrc
# ~/.bashrc
#
# This file is sourced for interactive non-login shells.
# It provides a feature-rich shell environment optimized for gaming,
# development, AI/ML, and security work on the AuroraMax GameHack distribution.
#
# Features:
# - Advanced prompt with git integration and performance metrics
# - Helper functions for common tasks
# - Performance optimizations
# - Security-conscious defaults
# - Integration with AuroraMax tools and services
# - All aliases are moved to ~/.bash_aliases for better organization

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ============================================================================
# Shell Options and Environment
# ============================================================================

# History configuration for better command recall
HISTCONTROL=ignoreboth:erasedups  # Ignore duplicates and commands starting with space
HISTSIZE=50000                    # Massive history for power users
HISTFILESIZE=100000               # Persistent history across sessions
HISTTIMEFORMAT="%F %T "           # Timestamp history entries
shopt -s histappend               # Append to history, don't overwrite
shopt -s cmdhist                  # Save multi-line commands as single entry

# Enhanced shell behavior
shopt -s checkwinsize             # Update LINES and COLUMNS after each command
shopt -s globstar                 # Enable ** for recursive globbing
shopt -s dotglob                  # Include hidden files in globbing
shopt -s extglob                  # Extended pattern matching
shopt -s nocaseglob              # Case-insensitive globbing
shopt -s cdspell                 # Correct minor cd spelling errors
shopt -s dirspell                # Correct directory spelling in tab completion
shopt -s autocd                  # Type directory name to cd into it
shopt -s no_empty_cmd_completion # Don't complete on empty line

# Bash 4+ features
if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
    shopt -s globasciiranges     # Make [a-z] work as expected
    shopt -s complete_fullquote  # Quote completions with special chars
    shopt -s direxpand           # Expand directory names on completion
fi

# ============================================================================
# Environment Variables
# ============================================================================

# AuroraMax specific paths
export AURORAMAX_HOME="/opt/auroramax"
export AURORAMAX_VERSION=$(cat /etc/auroramax-release 2>/dev/null | grep VERSION | cut -d= -f2 || echo "unknown")
export AURORAMAX_VARIANT=$(cat /etc/auroramax-release 2>/dev/null | grep VARIANT | cut -d= -f2 || echo "base")

# Enhanced PATH with AuroraMax directories
export PATH="$HOME/.local/bin:$AURORAMAX_HOME/bin:$PATH"
export PATH="$PATH:$HOME/.cargo/bin:$HOME/go/bin"

# Default programs
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export BROWSER="${BROWSER:-firefox}"
export TERMINAL="${TERMINAL:-konsole}"
export PAGER="${PAGER:-less}"

# Development environment
export MAKEFLAGS="-j$(nproc)"
export CCACHE_DIR="${CCACHE_DIR:-$HOME/.ccache}"
export PYTHONDONTWRITEBYTECODE=1  # Don't create .pyc files
export VIRTUAL_ENV_DISABLE_PROMPT=1  # We'll handle venv in our prompt

# Podman as Docker
export DOCKER_HOST="${DOCKER_HOST:-unix:///run/user/$(id -u)/podman/podman.sock}"

# Enhanced less options
export LESS="-R -F -X -i -M -x4 --mouse"
export LESSHISTFILE="$HOME/.cache/lesshist"

# Man page colors
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset
export LESS_TERMCAP_so=$'\E[1;44;33m'  # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# Gaming-specific environment
export MANGOHUD_CONFIG="$HOME/.config/MangoHud/MangoHud.conf"
export ENABLE_VKBASALT=0  # Disabled by default, enable per-game
export PROTON_LOG=0       # Disable Proton logging by default

# Security tool preferences
export METASPLOIT_FRAMEWORK_ROOT="/opt/metasploit-framework"
export JOHN_HOME="/usr/share/john"

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ============================================================================
# Color Definitions
# ============================================================================

# Color codes for easy reference
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support
    export COLOR_RESET='\[\033[0m\]'
    export COLOR_BOLD='\[\033[1m\]'
    export COLOR_DIM='\[\033[2m\]'
    
    # Regular colors
    export COLOR_BLACK='\[\033[0;30m\]'
    export COLOR_RED='\[\033[0;31m\]'
    export COLOR_GREEN='\[\033[0;32m\]'
    export COLOR_YELLOW='\[\033[0;33m\]'
    export COLOR_BLUE='\[\033[0;34m\]'
    export COLOR_MAGENTA='\[\033[0;35m\]'
    export COLOR_CYAN='\[\033[0;36m\]'
    export COLOR_WHITE='\[\033[0;37m\]'
    
    # Bright colors
    export COLOR_BRIGHT_BLACK='\[\033[1;30m\]'
    export COLOR_BRIGHT_RED='\[\033[1;31m\]'
    export COLOR_BRIGHT_GREEN='\[\033[1;32m\]'
    export COLOR_BRIGHT_YELLOW='\[\033[1;33m\]'
    export COLOR_BRIGHT_BLUE='\[\033[1;34m\]'
    export COLOR_BRIGHT_MAGENTA='\[\033[1;35m\]'
    export COLOR_BRIGHT_CYAN='\[\033[1;36m\]'
    export COLOR_BRIGHT_WHITE='\[\033[1;37m\]'
    
    # AuroraMax theme colors
    export AURORAMAX_PRIMARY='\[\033[38;5;51m\]'    # Bright cyan
    export AURORAMAX_SECONDARY='\[\033[38;5;165m\]'  # Purple
    export AURORAMAX_ACCENT='\[\033[38;5;214m\]'     # Orange
    export AURORAMAX_SUCCESS='\[\033[38;5;46m\]'     # Green
    export AURORAMAX_ERROR='\[\033[38;5;196m\]'      # Red
fi

# ============================================================================
# Advanced Prompt Configuration
# ============================================================================

# Function to get git branch and status
__git_prompt() {
    local branch=""
    local status=""
    
    # Check if we're in a git repository
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # Get branch name
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        
        # Get status indicators
        local git_status=$(git status --porcelain 2>/dev/null)
        if [[ -n $git_status ]]; then
            if [[ $git_status =~ ^[MADRC] ]]; then
                status+="+"  # Staged changes
            fi
            if [[ $git_status =~ ^.[MD] ]]; then
                status+="!"  # Unstaged changes
            fi
            if [[ $git_status =~ ^\?\? ]]; then
                status+="?"  # Untracked files
            fi
        fi
        
        # Check for ahead/behind
        local ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
        if [[ -n $ahead_behind ]]; then
            local ahead=$(echo $ahead_behind | awk '{print $1}')
            local behind=$(echo $ahead_behind | awk '{print $2}')
            [[ $ahead -gt 0 ]] && status+="↑$ahead"
            [[ $behind -gt 0 ]] && status+="↓$behind"
        fi
        
        echo " ${AURORAMAX_SECONDARY}(${branch}${status})${COLOR_RESET}"
    fi
}

# Function to get Python virtual environment
__venv_prompt() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local venv_name=$(basename "$VIRTUAL_ENV")
        echo " ${COLOR_YELLOW}[${venv_name}]${COLOR_RESET}"
    fi
}

# Function to get current toolbox/distrobox container
__container_prompt() {
    if [[ -f /run/.containerenv ]]; then
        local container_name=$(grep -oP '(?<=name=")[^"]+' /run/.containerenv 2>/dev/null || echo "container")
        echo " ${COLOR_MAGENTA}⬢${container_name}${COLOR_RESET}"
    fi
}

# Function to get system load indicator
__load_prompt() {
    local load=$(cut -d' ' -f1 /proc/loadavg)
    local cores=$(nproc)
    local load_percent=$(echo "scale=0; $load * 100 / $cores" | bc -l)
    
    if [[ $load_percent -gt 100 ]]; then
        echo " ${AURORAMAX_ERROR}●${COLOR_RESET}"  # High load
    elif [[ $load_percent -gt 75 ]]; then
        echo " ${AURORAMAX_ACCENT}●${COLOR_RESET}"  # Medium load
    else
        echo " ${AURORAMAX_SUCCESS}●${COLOR_RESET}"  # Low load
    fi
}

# Build the prompt
build_prompt() {
    local exit_code=$?
    
    # Start with newline for clarity
    PS1="\n"
    
    # User and hostname with AuroraMax colors
    if [[ $EUID -eq 0 ]]; then
        PS1+="${AURORAMAX_ERROR}╭─ \u@\h${COLOR_RESET}"  # Root in red
    else
        PS1+="${AURORAMAX_PRIMARY}╭─ \u@\h${COLOR_RESET}"
    fi
    
    # Add variant indicator if not base
    if [[ "$AURORAMAX_VARIANT" != "base" ]]; then
        PS1+=" ${COLOR_DIM}[${AURORAMAX_VARIANT}]${COLOR_RESET}"
    fi
    
    # System load indicator
    PS1+="$(__load_prompt)"
    
    # Current directory
    PS1+=" ${COLOR_BRIGHT_BLUE}\w${COLOR_RESET}"
    
    # Git information
    PS1+="$(__git_prompt)"
    
    # Python virtual environment
    PS1+="$(__venv_prompt)"
    
    # Container indicator
    PS1+="$(__container_prompt)"
    
    # Newline and command prompt
    PS1+="\n"
    
    # Show exit code if non-zero
    if [[ $exit_code -ne 0 ]]; then
        PS1+="${AURORAMAX_ERROR}╰─ [$exit_code]${COLOR_RESET} "
    else
        PS1+="${AURORAMAX_PRIMARY}╰─${COLOR_RESET} "
    fi
    
    # Root gets # prompt, users get $
    if [[ $EUID -eq 0 ]]; then
        PS1+="${AURORAMAX_ERROR}#${COLOR_RESET} "
    else
        PS1+="${AURORAMAX_PRIMARY}\$${COLOR_RESET} "
    fi
}

# Set the prompt command
PROMPT_COMMAND='build_prompt'

# ============================================================================
# Functions - Enhanced Utilities
# ============================================================================

# Enhanced cd with history
cd() {
    builtin cd "$@" && ls --color=auto --group-directories-first
}

# Create directory and cd into it
mkcd() { 
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.tar.xz)    tar xJf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *.xz)        xz -d "$1"      ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create a backup of a file
backup() {
    if [ -f "$1" ]; then
        cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"
        echo "Backup created: $1.bak.$(date +%Y%m%d_%H%M%S)"
    else
        echo "File not found: $1"
    fi
}

# Find files by name
ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

# Find directories by name
fd() {
    find . -type d -iname "*$1*" 2>/dev/null
}

# Get size of directory
dirsize() {
    du -sh "${1:-.}" | cut -f1
}

# Show top 10 largest files/directories
top10() {
    du -ah "${1:-.}" 2>/dev/null | sort -rh | head -10
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# Weather report
weather() {
    curl -s "wttr.in/${1:-}"
}

# Cheat sheet
cheat() {
    curl -s "cheat.sh/$1"
}

# System resource usage summary
resources() {
    echo "=== CPU Usage ==="
    top -bn1 | grep "Cpu(s)" | awk '{print "Usage: " 100-$8 "%"}'
    echo
    echo "=== Memory Usage ==="
    free -h | grep "^Mem"
    echo
    echo "=== Disk Usage ==="
    df -h / /home | grep -v tmpfs
    echo
    echo "=== GPU Usage ==="
    if command -v nvidia-smi &>/dev/null; then
        nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,power.draw --format=csv,noheader
    elif [ -f /sys/class/drm/card0/device/gpu_busy_percent ]; then
        echo "AMD GPU: $(cat /sys/class/drm/card0/device/gpu_busy_percent)% busy"
    else
        echo "No GPU monitoring available"
    fi
}

# Git repository stats
gitstats() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "=== Repository Stats ==="
        echo "Current branch: $(git branch --show-current)"
        echo "Total commits: $(git rev-list --all --count)"
        echo "Contributors: $(git shortlog -sn | wc -l)"
        echo "Files tracked: $(git ls-files | wc -l)"
        echo "Repository size: $(du -sh .git | cut -f1)"
        echo
        echo "=== Recent Activity ==="
        git log --pretty=format:"%h - %an, %ar : %s" --graph -10
    else
        echo "Not in a git repository"
    fi
}

# Development environment setup
devenv() {
    local env_type="${1:-python}"
    case "$env_type" in
        python)
            python3 -m venv venv
            source venv/bin/activate
            pip install --upgrade pip setuptools wheel
            echo "Python virtual environment created and activated"
            ;;
        node)
            npm init -y
            echo "Node.js project initialized"
            ;;
        rust)
            cargo init
            echo "Rust project initialized"
            ;;
        *)
            echo "Unknown environment type: $env_type"
            echo "Supported: python, node, rust"
            ;;
    esac
}

# Quick benchmark
bench() {
    local type="${1:-cpu}"
    case "$type" in
        cpu)
            echo "CPU benchmark (30 seconds)..."
            stress-ng --cpu $(nproc) --timeout 30s --metrics 2>/dev/null || echo "Install stress-ng for CPU benchmarking"
            ;;
        mem)
            echo "Memory benchmark..."
            sysbench memory run 2>/dev/null || echo "Install sysbench for memory benchmarking"
            ;;
        disk)
            echo "Disk write benchmark..."
            dd if=/dev/zero of=/tmp/benchmark bs=1M count=1024 oflag=dsync 2>&1 | grep -E "[0-9.]+ [MG]B/s"
            rm -f /tmp/benchmark
            ;;
        *)
            echo "Usage: bench [cpu|mem|disk]"
            ;;
    esac
}

# ============================================================================
# Helper Functions for AuroraMax
# ============================================================================

# Quick help function
help-auroramax() {
    cat << EOF
AuroraMax GameHack Quick Reference
==================================

System Management:
  update          - Update system, flatpaks, and firmware
  rollback        - Roll back to previous OS deployment  
  cleanup         - Clean up disk space
  sysinfo         - Show system information
  resources       - Show current resource usage

Performance:
  perf-gaming     - Optimize for gaming performance
  perf-balanced   - Return to balanced performance
  gpu-info        - Show GPU information
  bench [type]    - Run quick benchmark (cpu/mem/disk)

Development:
  devenv [type]   - Set up development environment
  gitstats        - Show git repository statistics
  serve [port]    - Start HTTP server in current directory

Containers:
  tb/toolbox      - Toolbox commands
  db/distrobox    - Distrobox commands
  k/kubectl       - Kubernetes commands

Gaming:
  shader-clear    - Clear all shader caches
  mangohud-on/off - Toggle MangoHud globally

For more commands, type 'just' or 'just --list'
EOF
}

# ============================================================================
# Load External Resources
# ============================================================================

# Enable color support for ls and grep - basic check before aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Load custom aliases from separate file
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ============================================================================
# Completion and Key Bindings
# ============================================================================

# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Custom completions
complete -cf sudo
complete -cf man
complete -cf which
complete -cf type

# Add completions for AuroraMax commands
if command -v just &>/dev/null; then
    eval "$(just --completions bash)"
fi

# Git completion
if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
    __git_complete g __git_main
    __git_complete gco _git_checkout
    __git_complete gb _git_branch
fi

# Kubernetes completion
if command -v kubectl &>/dev/null; then
    eval "$(kubectl completion bash)"
    complete -F __start_kubectl k
fi

# Key bindings for better navigation
bind '"\e[A": history-search-backward'  # Up arrow searches history
bind '"\e[B": history-search-forward'   # Down arrow searches history
bind '"\e[1;5C": forward-word'         # Ctrl+Right moves word forward
bind '"\e[1;5D": backward-word'        # Ctrl+Left moves word backward

# ============================================================================
# External Tool Integration
# ============================================================================

# Rust cargo environment
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# Go environment
if command -v go &>/dev/null; then
    export GOPATH="${GOPATH:-$HOME/go}"
    export PATH="$PATH:$GOPATH/bin"
fi

# Node Version Manager
if [ -f "$HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    . "$NVM_DIR/nvm.sh"
    . "$NVM_DIR/bash_completion"
fi

# FZF - Fuzzy finder
if [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
    . /usr/share/fzf/shell/key-bindings.bash
fi

# Zoxide - smarter cd
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# Starship prompt (optional - uncomment to use instead of custom prompt)
# if command -v starship &>/dev/null; then
#     eval "$(starship init bash)"
# fi

# ============================================================================
# Welcome Message and System Status
# ============================================================================

# Only show on first shell, not every subshell
if [ -z "$AURORAMAX_WELCOMED" ]; then
    export AURORAMAX_WELCOMED=1
    
    # Welcome banner
    if [ -f /etc/auroramax-release ]; then
        echo
        echo -e "${AURORAMAX_PRIMARY}╔══════════════════════════════════════════════════════╗${COLOR_RESET}"
        echo -e "${AURORAMAX_PRIMARY}║        Welcome to AuroraMax GameHack!                ║${COLOR_RESET}"
        echo -e "${AURORAMAX_PRIMARY}║                                                      ║${COLOR_RESET}"
        echo -e "${AURORAMAX_PRIMARY}║  Variant: ${AURORAMAX_VARIANT:-base}                                       ║${COLOR_RESET}"
        echo -e "${AURORAMAX_PRIMARY}║  Kernel:  $(uname -r)                    ║${COLOR_RESET}"
        echo -e "${AURORAMAX_PRIMARY}║                                                      ║${COLOR_RESET}"
        echo -e "${AURORAMAX_PRIMARY}║  Type 'just' to see available commands              ║${COLOR_RESET}"
        echo -e "${AURORAMAX_PRIMARY}║  Type 'help-auroramax' for quick reference          ║${COLOR_RESET}"
        echo -e "${AURORAMAX_PRIMARY}╚══════════════════════════════════════════════════════╝${COLOR_RESET}"
        echo
    fi
    
    # Quick system status
    if command -v fastfetch &>/dev/null; then
        fastfetch --logo small
    fi
fi

# ============================================================================
# Local Customizations
# ============================================================================

# Source local customizations if they exist
if [ -f "$HOME/.bashrc.local" ]; then
    . "$HOME/.bashrc.local"
fi

# Source work-specific configurations
if [ -f "$HOME/.bashrc.work" ]; then
    . "$HOME/.bashrc.work"
fi

# End of AuroraMax GameHack .bashrc