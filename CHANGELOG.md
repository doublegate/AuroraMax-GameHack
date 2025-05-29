# Changelog

All notable changes to the AuroraMax-GameHack project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-05-29

### Summary
First complete build-ready release of the init-minimal variant. All configuration files are in place, build system is fully operational, and the image is ready for compilation using BlueBuild.

### Added
- **Missing Configuration Files**:
  - `60-io-scheduler.rules`: Comprehensive I/O scheduler configuration for NVMe, SSDs, HDDs, and virtual devices
  - Verified presence of skeleton files (.bashrc and .bash_aliases)
- **Project Management**:
  - `to-dos/` directory for tracking project tasks and completion status
  - `ref_info/` directory for local reference materials (gitignored)
  - Comprehensive build checklist for init-minimal variant
- **Documentation**:
  - Version 0.1.0 designation in README
  - Build readiness status documentation
  - Updated project status to reflect completion

### Fixed
- **GRUB Configuration Path**: Corrected path from `common-files/etc/default/grub.d/` to `common-files/default/grub.d/` in both recipe.yml and Containerfile
- **Build Prerequisites**: Verified BlueBuild CLI (v0.9.12) and container runtimes (Podman 5.5.0, Docker 28.1.1) are installed

### Changed
- **Project Status**: Moved from "implementing" to "build-ready" status
- **.gitignore**: Added `ref_info/` directory to keep local notes private

## [Unreleased] - 2025-01-28

### Changed
- **Complete Multi-Variant Architecture Implementation**: Fully transitioned from single-image to multi-variant development approach
- **Build System Overhaul**: Implemented template-based build system with shared components
- **File Organization**: Restructured entire project with `common-files/`, `templates/`, and `variants/` directories
- **Documentation**: Updated README.md to reflect new multi-variant structure and build process

### Added
- **Template System**:
  - `base-build-script.sh`: Shared build functions for all variants
  - `base-containerfile.txt`: Template for variant Containerfiles
  - `base-recipe.yml`: BlueBuild recipe template
  - `build-bluebuild.sh`: BlueBuild integration script
  - `iso.toml`: ISO generation configuration
  - `packages-base.list`: Common package list
- **Variants Structure**:
  - `init-minimal/`: First implemented variant with minimal base system
    - Complete Containerfile with proper labeling
    - Variant-specific build.sh script
    - BlueBuild recipe.yml for declarative builds
    - Pre/post scripts for additional customization
    - Package list manifest
- **Common Files Implementation**:
  - **System Configuration** (`etc/`):
    - CPU scheduler tuning (BORE/LAVD support)
    - Memory management (MGLRU, ZRAM with zstd)
    - Network performance (TCP BBR, increased buffers)
    - Audio latency reduction (PulseAudio/PipeWire configs)
    - Security limits for gaming workloads
  - **Udev Rules** (`etc/udev/rules.d/`):
    - GPU performance profiles (61-auroramax-gpu-performance.rules)
    - Game controller support (62-auroramax-game-controllers.rules)
    - Network device optimization (63-auroramax-network-performance.rules)
    - Audio device configuration (64-auroramax-audio-performance.rules)
    - CPU governor management (65-auroramax-cpu-performance.rules)
    - USB device handling (66-auroramax-usb-devices.rules)
    - Virtual device support (67-auroramax-virtual-devices.rules)
    - Security device permissions (68-auroramax-security-devices.rules)
    - Power management (69-auroramax-power-management.rules)
    - Memory performance (70-auroramax-memory-performance.rules)
  - **Scripts** (`usr/bin/`):
    - `auroramax-firstboot.sh`: First boot configuration
    - `auroramax-performance.sh`: Performance tuning script
    - `auroramax-scheduler.sh`: CPU scheduler management
  - **Systemd Services** (`usr/lib/systemd/system/`):
    - `auroramax-firstboot.service`: One-time setup service
    - `auroramax-performance.service`: Boot-time performance optimization
    - `auroramax-scheduler.service`: Dynamic scheduler selection
  - **Justfiles** (`usr/share/justfiles/`):
    - `00-base.just`: Core system management
    - `01-performance.just`: Performance tuning commands
    - `02-hardware.just`: Hardware information and control
- **WirePlumber Configuration**: Audio device routing optimizations
- **GRUB Configuration**: Boot parameter management
- **Contributing Guidelines**: CONTRIBUTING.md for project contributors

### Removed
- **Legacy Build Files**:
  - `Containerfile`: Old single-variant containerfile
  - `build-auroramax.sh`: Replaced by variant-specific build scripts
  - `recipe.yml`: Moved to variant-specific locations
  - `create_dirs.sh`: No longer needed with new structure
- **Old File Structure**: Flat `files/` directory replaced by organized hierarchy

## [0.1.0] - 2025-01-28

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

[Unreleased]: https://github.com/doublegate/AuroraMax-GameHack/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/doublegate/AuroraMax-GameHack/releases/tag/v0.1.0