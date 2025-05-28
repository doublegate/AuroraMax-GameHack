# AuroraMax-GameHack

A custom Universal Blue image based on Aurora, specifically optimized for gaming performance and hardware compatibility. This immutable desktop operating system provides a rock-solid gaming platform with the latest optimizations and tools.

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

## 📦 Installation

### Method 1: Rebase from Existing Atomic Desktop

```bash
# For verified images (recommended)
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/YOUR_GITHUB_USERNAME/auroramax-gamehack:latest

# For testing/development
rpm-ostree rebase ostree-unverified-registry:ghcr.io/YOUR_GITHUB_USERNAME/auroramax-gamehack:latest
```

### Method 2: Fresh Installation
1. Download the latest Aurora ISO from [getaurora.dev](https://getaurora.dev)
2. Install Aurora normally
3. After installation, rebase to AuroraMax-GameHack using the commands above

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

### Modifying the Image

1. **Fork this repository**
2. **Edit configuration files**:
   - `recipe.yml`: Package list and modules
   - `files/`: Custom system files
   - `Containerfile`: Advanced build customization

3. **Build locally** (optional):
   ```bash
   ./build-auroramax.sh
   ```

4. **Push changes** to trigger automated builds

### Adding Packages

Edit `recipe.yml` and add packages to the appropriate section:

```yaml
# For RPM packages
rpm:
  install:
    - package-name

# For Flatpak applications  
default-flatpaks:
  notify: true
  install:
    - com.example.Application
```

### Custom System Files

Place files in the `files/` directory matching the filesystem hierarchy:
- `files/etc/`: System configuration
- `files/usr/`: System binaries and data
- `files/home/`: Default user configurations

## 🚀 Development

### Local Building

```bash
# Quick build script
./build-auroramax.sh

# Manual build with Podman
podman build -t auroramax-gamehack:test .

# Test in container
podman run -it --rm auroramax-gamehack:test bash
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
See `recipe.yml` for the complete list of pre-installed packages and Flatpaks.

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

**Note**: Replace `YOUR_GITHUB_USERNAME` with your actual GitHub username in the installation commands.