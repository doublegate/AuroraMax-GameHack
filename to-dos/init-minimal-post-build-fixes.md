# Init-Minimal Post-Build Fixes and Re-implementations

## Overview
This document tracks all the temporary workarounds, disabled features, and removed components that need to be re-implemented or fixed after the successful initial build of the init-minimal variant.

## Status Legend
- 🔴 Critical - Must fix before production
- 🟡 Important - Should fix soon
- 🟢 Nice to have - Can wait
- ⬜ Not started
- 🟨 In progress
- ✅ Completed

---

## 1. Image Signing and Keys 🔴

### ⬜ Re-enable Cosign Image Signing
- **What we disabled**: The entire image signing module in recipe.yml (lines 326-330)
- **Why**: BlueBuild was creating an empty stage-keys causing build failures
- **Files affected**:
  - `variants/init-minimal/recipe.yml` - signing module commented out
  - `variants/init-minimal/Containerfile` - stage-keys removed by build script
- **Fix needed**:
  - Re-enable the signing module in recipe.yml
  - Ensure cosign.pub is properly mounted during build
  - May need to report/fix BlueBuild's key handling

### ⬜ Fix Key Mounting in Containerfile
- **What happened**: BlueBuild generates empty `FROM scratch AS stage-keys`
- **Current workaround**: build-direct.sh removes the key mounting steps
- **Fix needed**:
  - Work with BlueBuild to fix key stage generation
  - Or implement custom key mounting solution

---

## 2. Removed Packages 🟡

### ⬜ Find Replacements for Unavailable Packages
These packages were removed because they weren't available in the repos:

1. **eza** (modern ls replacement)
   - **Alternative**: Could use `lsd` or stick with standard `ls`
   - **Location**: recipe.yml line 144 (commented out)

2. **mlocate** (file locator)
   - **Alternative**: Use `plocate` (faster, more modern)
   - **Location**: recipe.yml line 37 (commented out)

3. **neofetch** (system info display)
   - **Alternative**: Already using `fastfetch` which is better
   - **Location**: recipe.yml line 29 (commented out)

---

## 3. Mesa Graphics Drivers 🟡

### ⬜ Resolve Mesa Package Conflicts
- **What we removed**: All mesa-* packages (lines 115-118 in recipe.yml)
  - mesa-dri-drivers
  - mesa-vulkan-drivers
  - mesa-va-drivers
  - mesa-vdpau-drivers
- **Why**: Conflicts with packages already in base image
- **Fix needed**:
  - Determine if these are actually needed
  - If yes, find correct way to overlay/update mesa packages
  - May need to use rpm-ostree override commands

---

## 4. Repository Issues 🔴

### ⬜ Re-enable COPR Repositories
- **What we disabled**: Two COPR repos (lines 20-22 in recipe.yml)
  - `ublue-os/bazzite` COPR repo
  - `bazzite-org/kernel-bazzite` COPR repo
- **Why**: May not be compatible with current base image
- **Fix needed**:
  - Verify correct Fedora version (42)
  - Update repo URLs if needed
  - Test with proper base image

### ⬜ Re-enable Bazzite Kernel
- **What we commented out**: Bazzite kernel packages (lines 41-44)
  - kernel-bazzite
  - kernel-bazzite-devel
  - kernel-bazzite-headers
- **Why**: Depends on COPR repos being enabled
- **Fix needed**:
  - Enable COPR repos first
  - Then uncomment kernel packages

### ⬜ Fix Microsoft Repository Reference
- **Issue**: pre_script.sh had dnf copr commands
- **Current state**: Removed all dnf commands from pre_script.sh
- **Fix needed**:
  - Determine if Microsoft repo is actually needed
  - If yes, add proper repo configuration

---

## 5. Systemd Services 🟡

### ⬜ Re-enable Custom Systemd Services
- **What we disabled**: Three custom services (lines 299-301 in recipe.yml)
  - auroramax-firstboot.service
  - auroramax-performance.service
  - auroramax-scheduler.service
- **Why**: To avoid errors during initial build
- **Fix needed**:
  - Verify service files are properly installed
  - Re-enable in systemd module
  - Test that services start correctly

### ⬜ Re-enable ZRAM Service
- **What we disabled**: systemd-zram-setup@zram0.service (line 303)
- **Fix needed**:
  - Verify zram-generator is properly configured
  - Re-enable the service

---

## 6. Build Process Improvements 🟢

### ⬜ Fix BlueBuild Content-Based File Creation
- **Issue**: BlueBuild fails with content-based files in the files module
- **Workaround**: Moved /etc/auroramax-release creation to post_script.sh
- **Fix needed**:
  - Report issue to BlueBuild project
  - Find proper way to create files with content in recipe

### ⬜ Create Proper Build Pipeline
- **Current state**: Using custom build-direct.sh script
- **Fix needed**:
  - Make build-direct.sh more robust
  - Or fix BlueBuild issues to use standard process
  - Ensure GitHub Actions workflow will work

---

## 7. Generated/Temporary Files to Clean Up 🟢

### ⬜ Remove Temporary Build Artifacts
- **Files created during troubleshooting**:
  - `variants/init-minimal/Containerfile.fixed`
  - `variants/init-minimal/common-files/` (symlink)
  - Various backup files

### ⬜ Organize Build Scripts
- **Current state**: Multiple build scripts in different locations
- **Fix needed**:
  - Consolidate to one official build method
  - Document the chosen approach
  - Remove experimental scripts

---

## 8. Additional Packages to Consider 🟢

### ⬜ Graphics and Display Tools
- **Currently commented out**:
  - clinfo (OpenCL info tool) - line 123
  - glxinfo (OpenGL info tool) - line 124
- **Fix needed**:
  - Test if these work with current mesa setup
  - Add if they don't cause conflicts

### ⬜ Virtual Device Support
- **Currently commented out**:
  - akmod-v4l2loopback (Virtual video device) - line 69
- **Fix needed**:
  - Requires kernel headers to be available
  - Add after Bazzite kernel is working

---

## 9. Documentation Updates 🟡

### ⬜ Update Build Documentation
- **What needs updating**:
  - Document the actual build process that works
  - Note all workarounds and why they exist
  - Create troubleshooting guide

### ⬜ Update README
- **Current state**: Generic README
- **Fix needed**:
  - Add specific build instructions
  - Document known issues
  - Add requirements and prerequisites

---

## 10. Testing and Validation 🔴

### ⬜ Create Automated Tests
- **What's needed**:
  - Test that image builds successfully
  - Verify all packages are installed
  - Check that services can start
  - Validate performance optimizations

### ⬜ Create Installation ISO
- **Current state**: Have OCI image but no ISO
- **Fix needed**:
  - Use BlueBuild ISO creation
  - Test installation process
  - Document installation steps

---

## Priority Order for Fixes

### Phase 1 - Critical (Before any other variants)
1. Fix repository issues (COPR repos)
2. Re-enable Bazzite kernel
3. Re-enable custom systemd services
4. Create working ISO for testing

### Phase 2 - Important (Before production use)
1. Fix image signing
2. Resolve Mesa conflicts
3. Update documentation
4. Clean up build process

### Phase 3 - Nice to Have
1. Fix minor package issues
2. Add missing tools
3. Optimize build scripts
4. Create automated tests

---

## Notes
- Build Date: 2025-05-29
- Working Image: localhost/auroramax-gamehack-init-minimal:latest (d4ccce402f91)
- Size: 9.21 GB
- Build Method: custom build-direct.sh script

This list will be updated as fixes are implemented or new issues are discovered.