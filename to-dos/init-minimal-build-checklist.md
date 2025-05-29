# Init-Minimal Variant - Pre-Build Checklist

## Overview
This checklist tracks all tasks that need to be completed before the first build of the AuroraMax GameHack Init-Minimal variant.

## Status Legend
- ⬜ Not Started
- 🟨 In Progress
- ✅ Completed

---

## Critical Tasks (Must Complete)

### 1. ✅ Create Missing Configuration Files

#### a) IO Scheduler udev rule
- **File**: `common-files/etc/udev/rules.d/60-io-scheduler.rules`
- **Status**: ✅ Created (2025-05-29)
- **Features**:
  - NVMe devices: 'none' scheduler (hardware queue)
  - SATA/SCSI SSDs: 'kyber' scheduler for low latency
  - HDDs: 'bfq' scheduler for better fairness
  - Virtual devices: 'none' scheduler
  - Memory cards/USB: 'kyber' scheduler
  - Optimized queue parameters for SSDs/HDDs
  - SATA power management configuration
  - Optional debug logging

#### b) User skeleton .bashrc
- **File**: `common-files/etc/skel/.bashrc`
- **Status**: ✅ Present (20755 bytes)
- **Notes**: Verified as hidden file - includes AuroraMax customizations

#### c) User skeleton .bash_aliases
- **File**: `common-files/etc/skel/.bash_aliases`
- **Status**: ✅ Present (15377 bytes)
- **Notes**: Verified as hidden file - includes useful aliases

### 2. ✅ Fix Configuration Paths

#### GRUB configuration path
- **File**: `variants/init-minimal/recipe.yml` (line 259)
- **Status**: ✅ Fixed (2025-05-29)
- **Issue**: Referenced wrong path `common-files/etc/default/grub.d/10-auroramax.cfg`
- **Fix Applied**: Changed to `common-files/default/grub.d/10-auroramax.cfg`
- **Also Fixed**: Same path issue in `Containerfile` (line 75)

---

## Build Prerequisites

### 3. ✅ Install BlueBuild CLI
- **Status**: ✅ Installed (Verified 2025-05-29)
- **Version**: BlueBuild 0.9.12
- **Location**: `/home/parobek/.cargo/bin/bluebuild`
- **Build Info**: Built 2025-05-27 with rustc 1.87.0

### 4. ✅ Verify Container Runtime
- **Status**: ✅ Both Available (Verified 2025-05-29)
- **Podman**: Version 5.5.0 at `/usr/bin/podman` (Preferred for rootless builds)
- **Docker**: Version 28.1.1 at `/usr/bin/docker`
- **Recommendation**: Use Podman for this build

---

## Optional but Recommended

### 5. ⬜ Create Local Build Script
- **Status**: ⬜ Not Created
- **Template**: Available at `templates/build-bluebuild.sh`
- **Location**: Copy to `variants/init-minimal/build-local.sh`

### 6. ⬜ Test GitHub Actions Workflow
- **Status**: ⬜ Not Configured
- **Note**: Currently the workflow is at `.github/workflows/action.yml` but may need to be moved/renamed

---

## Verification Checklist

### 7. ✅ Project Structure
- **Status**: ✅ Verified Complete
- **Completed**: All required directories exist

### 8. ✅ Core Configuration Files
- **Status**: ✅ Complete
- **Completed**: 100% of configuration files are in place (all files created/verified)

### 9. ✅ BlueBuild Recipe
- **Status**: ✅ Complete
- **Files**: 
  - `variants/init-minimal/recipe.yml` ✅
  - `variants/init-minimal/Containerfile` ✅
  - `variants/init-minimal/pre_script.sh` ✅
  - `variants/init-minimal/post_script.sh` ✅

### 10. ✅ Package Lists
- **Status**: ✅ Complete
- **File**: `variants/init-minimal/packages-init-minimal.list` exists with comprehensive package selection

### 11. ✅ Signing Key
- **Status**: ✅ Present
- **File**: `cosign.pub` exists for image signing

---

## Next Steps After Completion

1. Run local build test
2. Verify image boots in VM
3. Test core functionality
4. Document any issues found
5. Prepare for next variant development

---

## Notes
- Last Updated: 2025-05-29 (All tasks completed, build prerequisites verified!)
- Variant: init-minimal
- Base Image: ghcr.io/ublue-os/kinoite-main:latest
- Status: **✅ READY FOR FIRST BUILD - ALL PREREQUISITES MET!**

## Build Command
From the `variants/init-minimal/` directory, run:
```bash
bluebuild build --recipe recipe.yml
```