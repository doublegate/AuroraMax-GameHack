# AuroraMax GameHack Complete Bash Aliases
# ~/.bash_aliases
#
# This file contains all command aliases for the AuroraMax GameHack distribution.
# It is sourced by ~/.bashrc for better organization and maintainability.
#
# Organization:
# - System & File Management
# - Safety Aliases
# - Colorization
# - System Administration
# - Process Management
# - Development Tools
# - Container & Virtualization
# - Kubernetes
# - Programming Languages
# - Gaming
# - Security & Networking
# - Hardware Information
# - Utilities
# - Quick Navigation

# ============================================================================
# System & File Management
# ============================================================================

# Enhanced ls aliases with colors and grouping
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -alFht'  # Sort by time, newest first
alias lz='ls -alFhS'  # Sort by size, largest first
alias ld='ls -d */'   # List directories only
alias l.='ls -d .*'   # List hidden files only
alias lx='ls -lXB'    # Sort by extension
alias lk='ls -lSr'    # Sort by size, smallest first

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'     # Go to previous directory
alias cd..='cd ..'    # Common typo

# ============================================================================
# Safety Aliases
# ============================================================================

# Interactive mode for dangerous operations
alias rm='rm -Iv'
alias cp='cp -iv'
alias mv='mv -iv'
alias ln='ln -iv'

# Create parent directories as needed
alias mkdir='mkdir -pv'

# ============================================================================
# Colorization
# ============================================================================

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'

# ============================================================================
# System Administration
# ============================================================================

# AuroraMax system management
alias update='just update'
alias rollback='just rollback'
alias sysinfo='just system-info'
alias cleanup='just cleanup'
alias check-health='just check-health'
alias deployments='just deployments'

# Power management
alias reboot='systemctl reboot'
alias poweroff='systemctl poweroff'
alias suspend='systemctl suspend'
alias hibernate='systemctl hibernate'

# Service management
alias sctl='systemctl'
alias sctlu='systemctl --user'
alias jctl='journalctl'
alias jctlf='journalctl -f'  # Follow logs

# ============================================================================
# Process Management
# ============================================================================

alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias pstree='pstree -U'
alias htop='htop -t'
alias btop='btop --utf-force'
alias top='top -d 1'
alias killall='killall -v'

# Memory and CPU
alias free='free -h'
alias vmstat='vmstat -w'

# ============================================================================
# Development Tools
# ============================================================================

# Git aliases
alias g='git'
alias gs='git status -sb'
alias gst='git status'
alias ga='git add'
alias gap='git add -p'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit -a'
alias gcam='git commit -am'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch -v'
alias gba='git branch -a -v'
alias gbd='git branch -d'
alias gd='git diff'
alias gdc='git diff --cached'
alias gdw='git diff --word-diff'
alias gp='git pull'
alias gpu='git push'
alias gpuo='git push -u origin'
alias gpf='git push --force-with-lease'
alias glog='git log --oneline --graph --decorate'
alias gloga='git log --oneline --graph --decorate --all'
alias glogp='git log --pretty=format:"%h %s" --graph'
alias gstash='git stash'
alias gpop='git stash pop'
alias greset='git reset'
alias gclean='git clean -fd'
alias gremote='git remote -v'
alias gfetch='git fetch'
alias gmerge='git merge'
alias grebase='git rebase'
alias gtag='git tag'
alias gshow='git show'
alias gblame='git blame'

# Build tools
alias make='make -j$(nproc)'
alias m='make'
alias mc='make clean'
alias mca='make clean all'
alias mi='make install'
alias cmake='cmake -GNinja'
alias cmakeclean='rm -rf CMakeCache.txt CMakeFiles build'
alias ninja='ninja -j$(nproc)'

# Code editing
alias v='${EDITOR:-vim}'
alias vi='vim'
alias nv='nvim'
alias code='codium'
alias subl='sublime_text'
alias nano='nano -w'

# File searching
alias fd='find . -type d -iname'
alias ff='find . -type f -iname'
alias fgrep='grep -F'
alias rgrep='grep -r'

# ============================================================================
# Container & Virtualization
# ============================================================================

# Podman/Docker
alias d='podman'
alias dc='podman-compose'
alias docker='podman'  # Compatibility alias
alias dps='podman ps'
alias dpsa='podman ps -a'
alias dimg='podman images'
alias drun='podman run --rm -it'
alias dexec='podman exec -it'
alias dlogs='podman logs -f'
alias dstop='podman stop'
alias drm='podman rm'
alias drmi='podman rmi'
alias dprune='podman system prune -a'

# Toolbox
alias tb='toolbox'
alias tbe='toolbox enter'
alias tbc='toolbox create'
alias tbl='toolbox list'
alias tbr='toolbox rm'
alias tbrun='toolbox run'

# Distrobox
alias db='distrobox'
alias dbe='distrobox enter'
alias dbc='distrobox create'
alias dbl='distrobox list'
alias dbr='distrobox rm'
alias dbstop='distrobox stop'

# ============================================================================
# Kubernetes
# ============================================================================

# Only set if kubectl is available
if command -v kubectl &>/dev/null; then
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgpa='kubectl get pods -A'
    alias kgs='kubectl get services'
    alias kgsa='kubectl get services -A'
    alias kgd='kubectl get deployments'
    alias kgda='kubectl get deployments -A'
    alias kgi='kubectl get ingress'
    alias kgia='kubectl get ingress -A'
    alias kgn='kubectl get nodes'
    alias kgns='kubectl get namespaces'
    alias kaf='kubectl apply -f'
    alias kdel='kubectl delete'
    alias kdelf='kubectl delete -f'
    alias klog='kubectl logs'
    alias klogf='kubectl logs -f'
    alias kexec='kubectl exec -it'
    alias kctx='kubectl config current-context'
    alias kns='kubectl config view --minify -o jsonpath="{..namespace}"'
    alias kdesc='kubectl describe'
    alias ktop='kubectl top'
    alias kroll='kubectl rollout'
    alias kscale='kubectl scale'
fi

# ============================================================================
# Programming Languages
# ============================================================================

# Python
alias py='python3'
alias py2='python2'
alias pip='python3 -m pip'
alias pip3='python3 -m pip'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate 2>/dev/null || source .venv/bin/activate 2>/dev/null || echo "No venv found"'
alias deactivate='deactivate 2>/dev/null || echo "No active venv"'
alias pyserve='python3 -m http.server'
alias pytest='python3 -m pytest'
alias pyprofile='python3 -m cProfile'
alias pytime='python3 -m timeit'
alias pydoc='python3 -m pydoc'

# Node.js/npm
alias npmg='npm install -g'
alias npmi='npm install'
alias npmr='npm run'
alias npmstart='npm start'
alias npmtest='npm test'
alias npmbuild='npm run build'

# Rust
alias cb='cargo build'
alias cr='cargo run'
alias ct='cargo test'
alias cc='cargo check'
alias cclean='cargo clean'
alias cupdate='cargo update'

# Go
alias gob='go build'
alias gor='go run'
alias got='go test'
alias goget='go get'
alias gomod='go mod'

# ============================================================================
# Gaming
# ============================================================================

# Performance profiles
alias perf-gaming='just optimize-gaming'
alias perf-balanced='just optimize-balanced'
alias perf-info='just show-performance-params'
alias gpu-info='just gpu-info'

# Gaming applications
alias steam='steam -silent'
alias lutris='lutris --no-gui-logs'
alias heroic='flatpak run com.heroicgameslauncher.hgl'
alias bottles='flatpak run com.usebottles.bottles'
alias retroarch='flatpak run org.libretro.RetroArch'

# Shader and cache management
alias shader-clear='just clear-shader-cache'
alias dxvk-clear='find ~/Games ~/.wine ~/.local/share/lutris -name "*.dxvk-cache" -delete'
alias vkd3d-clear='find ~/Games ~/.wine ~/.local/share/lutris -name "*.vkd3d-cache" -delete'

# MangoHud control
alias mangohud-on='export MANGOHUD=1'
alias mangohud-off='unset MANGOHUD'
alias mangohud-config='${EDITOR:-vim} ~/.config/MangoHud/MangoHud.conf'

# Proton management
alias proton-ge='just install-proton-ge'
alias proton-list='ls -la ~/.steam/root/compatibilitytools.d/'
alias proton-tricks='protontricks --gui'

# GameMode
alias gamemode-on='gamemoded -r'
alias gamemode-off='killall gamemoded'
alias gamemode-status='gamemoded -s'

# ============================================================================
# Security & Networking
# ============================================================================

# Network information
alias ports='sudo ss -tulnp'
alias listening='sudo lsof -i -P -n | grep LISTEN'
alias connections='sudo ss -tp'
alias myip='curl -s https://icanhazip.com'
alias localip='ip -br addr show'
alias arp='arp -n'
alias route='ip route'
alias ifconfig='ip addr'

# Network monitoring
alias netmon='sudo iftop'
alias nethogs='sudo nethogs'
alias tcptrack='sudo tcptrack -i any'
alias iptraf='sudo iptraf-ng'

# Security scanning
alias nmap-quick='sudo nmap -sV -sC -O -T4'
alias nmap-full='sudo nmap -sV -sC -O -p- -T4'
alias nmap-udp='sudo nmap -sU -sV -T4'
alias nmap-vulns='sudo nmap --script vuln'

# Firewall
alias fw='sudo firewall-cmd'
alias fwlist='sudo firewall-cmd --list-all'
alias fwreload='sudo firewall-cmd --reload'

# System monitoring
alias monitor='htop'
alias diskmon='iotop'
alias sysmon='glances'

# ============================================================================
# Hardware Information
# ============================================================================

alias cpuinfo='lscpu'
alias meminfo='free -h'
alias diskinfo='lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,LABEL'
alias diskspace='df -h | grep -v loop | grep -v tmpfs'
alias gpuinfo='lspci -k | grep -A 3 -E "(VGA|3D)"'
alias usbinfo='lsusb -t'
alias pciinfo='lspci -vnn'
alias sensors='sensors | grep -E "^(Core|temp|fan)"'
alias dmesg='dmesg --color=always'

# System info
alias osinfo='cat /etc/os-release'
alias kernelinfo='uname -a'
alias systeminfo='inxi -F'
alias boottime='systemd-analyze'
alias bootblame='systemd-analyze blame | head -20'
alias bootchart='systemd-analyze plot > /tmp/bootchart.svg && xdg-open /tmp/bootchart.svg'

# ============================================================================
# Package Management
# ============================================================================

# Flatpak
alias fpinstall='flatpak install'
alias fprun='flatpak run'
alias fplist='flatpak list'
alias fpupdate='flatpak update'
alias fpsearch='flatpak search'
alias fpremove='flatpak remove'
alias fpinfo='flatpak info'

# DNF (in toolbox/container)
alias dnfi='sudo dnf install'
alias dnfs='sudo dnf search'
alias dnfu='sudo dnf update'
alias dnfr='sudo dnf remove'
alias dnfinfo='sudo dnf info'
alias dnfclean='sudo dnf clean all'

# ============================================================================
# Utilities
# ============================================================================

# Archive operations
alias tarz='tar -czf'
alias tarx='tar -xzf'
alias tarlist='tar -tzf'

# Text processing
alias h='history'
alias hgrep='history | grep'
alias less='less -R'
alias more='less'
alias head='head -n 20'
alias tail='tail -n 20'
alias tailf='tail -f'

# File operations
alias trash='gio trash'
alias untrash='gio trash --restore'
alias emptytrash='gio trash --empty'

# Disk usage
alias duh='du -h --max-depth=1 | sort -hr'
alias duf='du -sh * | sort -hr'
alias dfh='df -h | grep -v tmpfs | grep -v loop'
alias ncdu='ncdu --color dark'

# System utilities
alias reload='source ~/.bashrc'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias timestamp='date +%Y%m%d_%H%M%S'
alias week='date +%V'
alias calc='bc -l'
alias sha='shasum -a 256'
alias md5='md5sum'

# External services
alias weather='curl wttr.in'
alias weatherfull='curl v2.wttr.in'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'
alias cheat='curl cheat.sh/'
alias dict='curl dict.org/d:'
alias ipinfo='curl ipinfo.io'
alias rates='curl rate.sx'

# Misc utilities
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias beep='echo -e "\a"'
alias cls='clear'
alias please='sudo $(history -p !!)'
alias fucking='sudo'

# ============================================================================
# Quick Navigation
# ============================================================================

alias home='cd ~'
alias docs='cd ~/Documents'
alias dl='cd ~/Downloads'
alias dev='cd ~/Development'
alias games='cd ~/Games'
alias pics='cd ~/Pictures'
alias vids='cd ~/Videos'
alias music='cd ~/Music'
alias desktop='cd ~/Desktop'
alias config='cd ~/.config'
alias tmp='cd /tmp'
alias opt='cd /opt'
alias usr='cd /usr'
alias etc='cd /etc'
alias var='cd /var'

# AuroraMax specific
alias auroramax='cd $AURORAMAX_HOME'
alias justfiles='cd /usr/share/justfiles'

# ============================================================================
# Quick Config Editing
# ============================================================================

alias bashrc='${EDITOR:-vim} ~/.bashrc'
alias aliases='${EDITOR:-vim} ~/.bash_aliases'
alias vimrc='${EDITOR:-vim} ~/.vimrc'
alias sshconfig='${EDITOR:-vim} ~/.ssh/config'
alias hosts='sudo ${EDITOR:-vim} /etc/hosts'
alias fstab='sudo ${EDITOR:-vim} /etc/fstab'
alias grubconfig='sudo ${EDITOR:-vim} /etc/default/grub'
alias sources='sudo ${EDITOR:-vim} /etc/apt/sources.list'

# ============================================================================
# Conditional Aliases
# ============================================================================

# Only if exa is installed (modern ls replacement)
if command -v exa &>/dev/null; then
    alias ls='exa --group-directories-first'
    alias ll='exa -la --group-directories-first'
    alias lt='exa -la --sort=modified'
    alias tree='exa --tree'
fi

# Only if bat is installed (modern cat replacement)
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain'
    alias catp='bat'
fi

# Only if ripgrep is installed
if command -v rg &>/dev/null; then
    alias grep='rg'
fi

# Only if fd is installed
if command -v fd &>/dev/null; then
    alias find='fd'
fi

# End of AuroraMax GameHack .bash_aliases