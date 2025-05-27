# AuroraMax GameHack

A custom Universal Blue image based on Aurora, optimized for gaming.

## Features

- Based on Aurora (Universal Blue's KDE variant)
- Includes gaming optimizations:
  - Gamescope compositor
  - MangoHud performance overlay
  - vkBasalt post-processing
  - GameMode performance governor
  - Steam device support
  - Joystick wake support
  - AntiMicroX controller mapping

## Installation

### Using Pre-built Images

```bash
# Rebase to this image
rpm-ostree rebase ostree-unverified-registry:ghcr.io/YOUR_GITHUB_USERNAME/auroramax-gamehack:main
```

### Building Your Own

1. Fork this repository
2. Generate a signing keypair:
   ```bash
   cosign generate-key-pair
   ```
3. Add the private key to your repository secrets as `SIGNING_SECRET`
4. Replace `cosign.pub` with your public key
5. Enable GitHub Actions and push to trigger a build

## Customization

### Adding Packages

Edit the `Containerfile` and add packages to the `rpm-ostree install` command.

### Adding Configuration Files

Place files in the `files/` directory following the filesystem hierarchy. For example:
- `files/etc/` for system configuration
- `files/usr/` for system files

## Development

```bash
# Build locally
podman build -t auroramax-gamehack:test .

# Test in a container
podman run -it auroramax-gamehack:test bash
```

## Based On

- [Universal Blue](https://universal-blue.org/)
- [Aurora](https://getaurora.dev/)
- [Fedora Atomic](https://fedoraproject.org/atomic-desktops/)