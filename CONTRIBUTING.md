## Building AuroraMax GameHack

### Prerequisites

- Podman or Docker
- Git
- 8GB+ RAM recommended
- 20GB+ free disk space

### Local Build Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/doublegate/auroramax-gamehack.git
   cd auroramax-gamehack
   ```

2. **Build a specific variant:**
   ```bash
   # Build using Podman
   podman build -f variants/init-gaming/Containerfile \
     --build-arg VARIANT_NAME=init-gaming \
     -t auroramax-gamehack:init-gaming-local .
   
   # Or using Docker
   docker build -f variants/init-gaming/Containerfile \
     --build-arg VARIANT_NAME=init-gaming \
     -t auroramax-gamehack:init-gaming-local .
   ```

3. **Test the image:**
   ```bash
   # Create a test deployment
   sudo rpm-ostree rebase ostree-unverified-registry:localhost/auroramax-gamehack:init-gaming-local
   ```

### Creating a New Variant

1. **Create variant directory:**
   ```bash
   mkdir -p variants/my-variant/{files,files/etc,files/usr/share/justfiles}
   ```

2. **Copy base templates:**
   ```bash
   cp templates/Containerfile.template variants/my-variant/Containerfile
   cp templates/build.sh.template variants/my-variant/build.sh
   ```

3. **Create package list:**
   ```bash
   # Start with base packages
   cp packages-base.list variants/my-variant/packages-my-variant.list
   # Add your variant-specific packages
   ```

4. **Customize the build:**
   - Edit `Containerfile` to set your variant name
   - Modify `build.sh` to add variant-specific logic
   - Add configuration files to `files/`
   - Create variant-specific justfiles

5. **Test your variant:**
   ```bash
   # Build locally first
   ./scripts/build-local.sh my-variant
   ```

### Debugging Build Issues

- **Check build logs:** Build output is verbose by default
- **Shell into build container:**
  ```bash
  podman run -it --rm ghcr.io/ublue-os/kinoite-main:42 /bin/bash
  ```
- **Verify package availability:**
  ```bash
  dnf search package-name
  ```
- **Test configurations:** Mount your files directory and test
  ```bash
  podman run -it --rm -v ./common-files:/tmp/test:z fedora:42 /bin/bash
  ```

### Working with Just Commands

1. **Adding new just commands:**
   - Common commands go in `/usr/share/justfiles/00-base.just`
   - Variant-specific commands go in numbered files (e.g., `10-gaming.just`)
   - Use descriptive names and include help text

2. **Testing just commands:**
   ```bash
   # Test in a toolbox
   toolbox create --image localhost/auroramax-gamehack:variant-local test
   toolbox enter test
   just --list
   ```

3. **Just command best practices:**
   - Always use `set -euo pipefail` in bash recipes
   - Provide user feedback with echo statements
   - Use emoji for visual clarity (✅ ❌ 🔄 ⚠️)
   - Include confirmation prompts for destructive actions

### Package Management Guidelines

1. **Package selection criteria:**
   - Essential for variant functionality
   - Not easily available as Flatpak
   - Requires system integration
   - Performance-critical

2. **Flatpak vs RPM layering:**
   - Use Flatpaks for GUI applications when possible
   - Layer RPMs for system tools, drivers, and libraries
   - Document why specific packages are layered

3. **Managing package conflicts:**
   - Test package combinations thoroughly
   - Use `dnf install --assumeno` to preview changes
   - Document known conflicts in variant README

### Configuration File Standards

1. **File locations:**
   ```
   /etc/sysctl.d/          # Kernel parameters
   /etc/udev/rules.d/      # Device rules
   /etc/modprobe.d/        # Module parameters
   /etc/systemd/system/    # Systemd units
   /usr/share/justfiles/   # Just commands
   ```

2. **Naming conventions:**
   - Prefix with priority number (e.g., `99-auroramax.conf`)
   - Use descriptive names
   - Include variant name for variant-specific configs

3. **Documentation:**
   - Include header comments explaining purpose
   - Document any performance/security tradeoffs
   - Reference source of optimizations

### Testing Checklist

Before submitting a PR for a new variant or major changes:

- [ ] Build completes without errors
- [ ] Image boots successfully
- [ ] All `just` commands work as expected
- [ ] Variant-specific features are functional
- [ ] No regression in base functionality
- [ ] Documentation is updated
- [ ] Package manifest is accurate
- [ ] Commit follows conventional commits format

### Performance Testing

1. **Benchmark before and after changes:**
   ```bash
   # CPU performance
   just benchmark cpu
   
   # Memory performance
   just benchmark memory
   
   # Disk I/O
   just benchmark disk
   ```

2. **Monitor resource usage:**
   ```bash
   # During build
   podman stats
   
   # Runtime overhead
   just check-health
   ```

### Security Considerations

1. **Review new packages for:**
   - Active maintenance
   - Security track record
   - Minimal privilege requirements
   - No unnecessary network services

2. **Validate configurations:**
   - Don't disable security features by default
   - Document any security tradeoffs
   - Test with `lynis audit system`

### Submitting Changes

1. **Branch naming:**
   - `feature/variant-name` for new variants
   - `fix/issue-description` for bug fixes
   - `enhance/feature-name` for improvements

2. **Commit messages:**
   ```
   feat(gaming): add MangoHud configuration
   fix(base): correct ZRAM size calculation
   docs(contrib): update build instructions
   ```

3. **Pull request checklist:**
   - Descriptive title and description
   - Link related issues
   - Include test results
   - Update relevant documentation
   - Add yourself to CONTRIBUTORS.md

### Getting Help

- **Discord:** Join our community for real-time help
- **GitHub Discussions:** For longer-form questions
- **Issue Tracker:** For bug reports and feature requests

### Troubleshooting Common Issues

1. **"Package not found" errors:**
   - Verify repository is enabled
   - Check package name spelling
   - Try searching: `dnf search keyword`

2. **Build failures:**
   - Check GitHub Actions for working examples
   - Verify base image is accessible
   - Review recent changes to dependencies

3. **Performance issues:**
   - Profile with `perf` or `sysprof`
   - Check for unnecessary services
   - Verify optimization flags are applied
