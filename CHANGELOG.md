# Changelog

All notable changes to the AuroraMax-GameHack project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2025-01-28

### Added
- **Multi-stage Containerfile**: Complete rewrite using sophisticated multi-stage build approach for better caching and modularity
- **BlueBuild Modules System**: Migrated to modular build approach with dedicated modules for:
  - rpm-ostree package management
  - Default Flatpak applications
  - Custom file deployment
  - 1Password integration (bling module)
  - Image signing
- **Enhanced CI/CD Pipeline**: 
  - Support for version tagging (v*.*.* pattern)
  - Multiple trigger strategies (PR, scheduled, tags, manual)
  - Sophisticated tagging system for different build scenarios
  - OCI version labeling
  - Deployment job with placeholder steps
  - Upgraded BlueBuild action from v1.6 to v1.8.1
- **Local Build Script** (`build-auroramax.sh`): Automated Podman build and GHCR deployment
- **System Optimizations**:
  - Kernel parameters for gaming (`vm.max_map_count`)
  - Network optimizations (TCP Fast Open, MTU probing)
  - CAKE qdisc for improved network queuing
- **Just Command System**: User-friendly management commands
  - System updates (OS, Flatpaks, firmware)
  - CPU governor management
  - Hardware information display
- **Gaming Software**:
  - Bottles (Windows compatibility layer)
  - CoreCtrl (GPU control)
  - Piper (gaming mouse configuration)
  - Additional gaming-focused Flatpaks
- **Comprehensive Documentation**: Completely rewritten README with detailed installation, usage, and customization instructions

### Changed
- **Project Name**: Standardized from `auroramax-gamehack` to `AuroraMax-GameHack`
- **Base Image**: Updated from `aurora-main` to `aurora`
- **Version Strategy**: Changed from fixed version `41` to `latest`
- **Module Versions**: All BlueBuild modules now use `@latest` tags
- **Package Management**: Moved Lutris from RPM to Flatpak due to COPR repository issues
- **Build Workflow**: Renamed from "Build and Deploy AuroraMax GameHack Linux" to "Build and Deploy AuroraMax-GameHack"
- **Container Registry**: Using digest-based image references for better immutability
- **File Organization**: Better structure with organized system files in `files/` directory

### Fixed
- **COPR Repository Issues**: Addressed missing repositories by migrating affected packages to Flatpak
- **Build Caching**: Implemented proper cache mounts for rpm-ostree and dnf
- **Image Signing**: Proper cosign integration with public key management

### Removed
- **Temporarily Disabled**:
  - `joystickwake` (COPR repository not currently enabled)
  - `io.github.benjamimgois.goverlay` Flatpak (not found in current repos)
  - `gamemoded.service` (service not available in current base image)

### Security
- Implemented proper image signing with cosign
- Added comprehensive OCI labels for better traceability
- Pinned base image using SHA256 digest

## [0.1.0] - 2025-01-20

### Initial Release
- Basic AuroraMax-GameHack image based on Aurora
- Core gaming packages: Gamescope, MangoHud, vkBasalt, GameMode
- Steam and gaming peripheral support
- Simple Containerfile-based build system
- Basic GitHub Actions workflow
- Initial documentation

[Unreleased]: https://github.com/YOUR_GITHUB_USERNAME/AuroraMax-GameHack/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/YOUR_GITHUB_USERNAME/AuroraMax-GameHack/releases/tag/v0.1.0