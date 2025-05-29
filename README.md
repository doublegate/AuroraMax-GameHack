# AuroraMax - Gaming & Hacking Linux

**Version: 0.1.0 - Init-Minimal Variant** (Build Ready: 2025-05-29)

An ambitious Universal Blue-based Linux distribution built on Fedora Kinoite (KDE Plasma) that delivers the ultimate all-in-one powerhouse OS for gaming, development, AI/ML, and security research. This immutable desktop operating system provides a rock-solid platform with aggressive performance optimizations, comprehensive toolsets, and an innovative phased development approach.

![AuroraMax GameHack Logo](images/auroramax-logo.png)

> A next-generation Universal Blue atomic image built on Fedora Kinoite (KDE) that delivers a powerful all-in-one gaming workstation with developer tools, retro game emulation, and cutting-edge performance optimizations.

[![Build](https://github.com/doublegate/AuroraMax-GameHack/actions/workflows/action.yml/badge.svg)](https://github.com/doublegate/AuroraMax-GameHack/actions/workflows/action.yml)
[![ISO](https://github.com/doublegate/AuroraMax-GameHack/actions/workflows/build-iso.yml/badge.svg)](https://github.com/doublegate/AuroraMax-GameHack/actions/workflows/build-iso.yml)

## Features

AuroraMax GameHack combines five powerful toolkits into one immutable, atomic OS:

### 🎮 Comprehensive Gaming Platform
- Pre-configured Steam, Lutris, ProtonUp-Qt, and Heroic launcher
- EmuDeck with RetroArch for full retro gaming support
- MangoHud, vkBasalt, LatencyFleX performance tools
- Gamescope session for console-like experience

### 💻 Developer Workstation
- Complete language stacks: GCC, Clang, Rust, Python, Go, Node.js, Java
- VS Code (Codium) with DevContainer support
- Container tools: Podman, Docker CLI, Kubernetes utilities
- Cloud SDKs for AWS, GCP, and Azure

### 🧠 AI/ML Toolkit
- CUDA, PyTorch, TensorFlow with GPU support
- JupyterLab for data science workflows
- ONNX Runtime and Hugging Face Transformers
- OpenCL, ROCm, and Intel oneAPI support

### 🔒 Security Suite
- Complete penetration testing toolkit (Nmap, Metasploit, Burp Suite)
- Password cracking (John, Hashcat) and wireless tools (Aircrack-ng)
- Forensics utilities (Autopsy, Volatility) and reverse engineering (Ghidra, Radare2)
- Network analysis with Wireshark and tcpdump

### ⚡ Performance Optimizations
- Custom kernel with BORE/LAVD CPU schedulers for reduced latency
- Kyber I/O scheduler for SSDs, BFQ for HDDs
- ZRAM swap with zstd compression
- GameMode and advanced CPU governor control

All this packaged in an immutable, atomic image with transactional updates and automatic rollback capability.

## 🚀 Project Vision

AuroraMax GameHack combines:
- **Gaming Excellence**: Steam, Lutris, emulation, and performance optimizations
- **Development Power**: Comprehensive toolchains, containers, and cloud tools
- **AI/ML Capabilities**: PyTorch, TensorFlow, and CUDA support
- **Security Arsenal**: Penetration testing, forensics, and offensive/defensive tools
- **Immutable Architecture**: Atomic updates with easy rollbacks via rpm-ostree
- **Performance First**: BORE scheduler, MGLRU, Kyber I/O, and aggressive optimizations

## 🎮 Key Features

### Gaming Enhancements
- **Gamescope**: Wayland compositor designed for gaming
- **MangoHud**: Advanced performance overlay with detailed metrics
- **vkBasalt**: Post-processing layer for enhanced visuals
- **GameMode**: Automatic performance optimization when gaming
- **Steam**: Native Steam client with full hardware support
- **Bottles**: Windows application and game compatibility layer
- **Lutris**: Universal game launcher (via Flatpak)
- **CoreCtrl**: GPU overclocking and fan control
- **AntiMicroX**: Advanced controller mapping
- **Piper**: Gaming mouse configuration

### System Optimizations
- **Kernel Parameters**: Optimized `vm.max_map_count` for games requiring many memory mappings
- **Network Tuning**: TCP Fast Open and MTU probing enabled for better online gaming
- **Performance Governors**: Easy CPU governor switching via `just` commands
- **Hardware Acceleration**: Full support for AMD, NVIDIA, and Intel GPUs

### Desktop Environment
- **KDE Plasma**: Feature-rich desktop with excellent gaming integration
- **Wayland/X11**: Support for both display protocols
- **Flatpak**: Sandboxed applications with the latest versions
- **Dark Aurora Theme**: Cohesive dark aesthetic across the system

### Development Environment
- **Languages**: C/C++, Rust, Python, Go, Java, Node.js
- **IDEs**: VS Code (Codium) with DevContainer support
- **Container Tools**: Podman, Docker CLI, Kubernetes
- **Cloud SDKs**: AWS, GCP, Azure
- **Build Systems**: CMake, Meson, Ninja

### Security Tools
- **Network**: Nmap, Wireshark, Masscan
- **Web**: Burp Suite, OWASP ZAP, Nikto
- **Exploitation**: Metasploit, sqlmap
- **Wireless**: Aircrack-ng, Reaver
- **Forensics**: Autopsy, Volatility

## 🔧 Development Approach

AuroraMax follows a sophisticated 4-phase iterative development process:

### Phase 1: Seven Init Variants
Specialized variants exploring different philosophies:
- **init-minimal**: Lean base for customization
- **init-stable**: Rock-solid reliability focus
- **init-cuttingedge**: Latest stable software
- **init-ux**: User-friendly defaults
- **init-dev**: Comprehensive development environment
- **init-gaming**: Ultimate gaming experience
- **init-hacking**: Security testing toolkit

### Phase 2: Synthesis I → SemiFinal
Merge best features from all Init variants into one cohesive SemiFinal variant.

### Phase 3: LLM Refinement → 3 Recommend Variants
AI-driven analysis to generate enhanced variants focusing on security, performance, and innovation.

### Phase 4: Release Candidate
Final synthesis and optimization into production-ready release.

**Current Status**: Version 0.1.0 - Init-minimal variant complete and build-ready. All configuration files created, build prerequisites verified, and ready for first OCI image build.

## 📦 Installation

### Method 1: Rebase from Existing Atomic Desktop

```bash
# For verified images (recommended)
# Replace <variant> with: init-minimal, init-stable, init-gaming, etc.
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/doublegate/auroramax-gamehack:<variant>

# For testing/development
rpm-ostree rebase ostree-unverified-registry:ghcr.io/doublegate/auroramax-gamehack:<variant>
```

### Method 2: Fresh Installation
1. Download the latest Aurora ISO from [getaurora.dev](https://getaurora.dev)
2. Install Aurora normally
3. After installation, rebase to your chosen AuroraMax-GameHack variant

### Available Variants
- `init-minimal`: Minimal base system
- `init-stable`: Conservative, stability-focused
- `init-cuttingedge`: Latest packages and features
- `init-ux`: Enhanced user experience
- `init-dev`: Development-focused tools
- `init-gaming`: Gaming optimizations and tools
- `init-hacking`: Security research and pentesting

## 🛠️ Usage

### System Management Commands

AuroraMax-GameHack includes a comprehensive `just` command system for easy management:

```bash
# Show all available commands
just

# Update everything (OS, Flatpaks, firmware)
just update

# CPU Performance Management
just performance-mode          # Maximum performance
just balanced-mode            # Balanced performance/power
just powersave-mode          # Power saving mode
just show-governor           # Display current CPU governor

# Hardware Information
just hardware-info           # Show detailed hardware information
```

### Gaming Tools

#### Launch Games
- **Steam**: Available in the application menu
- **Bottles**: For Windows games and applications
- **Lutris**: Universal game launcher (install via Software Center)

#### Performance Monitoring
- **MangoHud**: Automatically enabled for many games
  ```bash
  # Enable for any game
  mangohud %command%
  ```
- **CoreCtrl**: GPU control panel for overclocking and monitoring

#### Controller Configuration
- **AntiMicroX**: Map controller inputs to keyboard/mouse
- **Piper**: Configure gaming mice

## 🔧 Customization

### Project Structure

```
auroramax-gamehack/
├── common-files/          # Shared across all variants
│   ├── etc/              # System configurations
│   ├── usr/              # Scripts and systemd units
│   └── default/          # GRUB configuration
├── templates/            # Base build templates
├── variants/             # Variant-specific builds
│   └── init-minimal/     # Example variant
│       ├── Containerfile
│       ├── build.sh
│       ├── recipe.yml    # BlueBuild recipe
│       └── packages-init-minimal.list
└── scripts/              # Helper scripts
```

### Modifying a Variant

1. **Fork this repository**
2. **Choose a variant** to modify in `variants/`
3. **Edit variant files**:
   - `Containerfile`: Container build definition
   - `build.sh`: Installation and configuration script
   - `packages-*.list`: Package list for the variant
   - `recipe.yml`: BlueBuild recipe (if using BlueBuild)

4. **Test locally**:
   ```bash
   cd variants/init-minimal
   podman build -t auroramax-test .
   ```

5. **Push changes** to trigger automated builds

### Adding System Files

**Common files** (shared across variants):
- Place in `common-files/` following Linux filesystem hierarchy
- Example: `common-files/etc/sysctl.d/99-auroramax.conf`

**Variant-specific files**:
- Place in `variants/<variant>/files/`
- Will override common files if same path exists

## 🚀 Development

### Local Building

```bash
# Build a specific variant
cd variants/init-minimal
podman build -t auroramax-init-minimal:test .

# Build with custom Fedora version
podman build --build-arg FEDORA_VERSION=41 -t auroramax-init-minimal:f41 .

# Test in container
podman run -it --rm auroramax-init-minimal:test bash

# Build ISO (requires additional tooling)
scripts/build-iso.sh init-minimal
```

### CI/CD Pipeline

The project uses GitHub Actions for automated builds:
- **Triggers**: Push to main, PRs, tags, manual dispatch
- **Schedule**: Nightly builds at 00:00 UTC
- **Outputs**: Container images pushed to GitHub Container Registry
- **Signing**: All images are signed with cosign for verification

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## 📋 System Requirements

### Minimum
- **CPU**: x86_64 processor with SSE4.2
- **RAM**: 4GB (8GB recommended)
- **Storage**: 20GB free space
- **GPU**: Any GPU with Vulkan support

### Recommended
- **CPU**: Modern AMD Ryzen or Intel Core processor
- **RAM**: 16GB or more
- **Storage**: 50GB+ free space on NVMe SSD
- **GPU**: AMD RDNA2+, NVIDIA RTX 20+, or Intel Arc

## 🔒 Security

- **Immutable base**: System files are read-only
- **Signed images**: All builds are cryptographically signed
- **Automatic updates**: Background updates without interruption
- **Sandboxed apps**: Flatpak applications run in isolation

## 📚 Documentation

### Included Packages
Each variant has its own package list:
- Common packages: `templates/packages-base.list`
- Variant-specific: `variants/<variant>/packages-*.list`
- BlueBuild recipes: `variants/<variant>/recipe.yml`

### Troubleshooting
- **Rebasing issues**: Ensure you have sufficient disk space
- **Performance problems**: Check CPU governor with `just show-governor`
- **GPU issues**: Verify drivers are loaded with `just hardware-info`

## 🤝 Credits

Built on top of:
- [Universal Blue](https://universal-blue.org/) - Custom image framework
- [Aurora](https://getaurora.dev/) - KDE-focused Atomic desktop
- [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) - Immutable base OS
- [BlueBuild](https://blue-build.org/) - Declarative image building

## 📄 License

This project follows the same licensing as Universal Blue and Fedora.

---
