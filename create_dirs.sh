#!/bin/bash

# Root directory
ROOT="auroramax-gamehack"

# List of directories to create
DIRS=(
  "$ROOT/.github/workflows"
  "$ROOT/common-files/etc/environment.d"
  "$ROOT/common-files/etc/kernel/cmdline.d"
  "$ROOT/common-files/etc/modprobe.d"
  "$ROOT/common-files/etc/modules-load.d"
  "$ROOT/common-files/etc/motd.d"
  "$ROOT/common-files/etc/NetworkManager/conf.d"
  "$ROOT/common-files/etc/pulse/daemon.conf.d"
  "$ROOT/common-files/etc/security/limits.d"
  "$ROOT/common-files/etc/skel"
  "$ROOT/common-files/etc/sysconfig"
  "$ROOT/common-files/etc/sysctl.d"
  "$ROOT/common-files/etc/systemd/journald.conf.d"
  "$ROOT/common-files/etc/systemd/logind.conf.d"
  "$ROOT/common-files/etc/systemd/system"
  "$ROOT/common-files/etc/tmpfiles.d"
  "$ROOT/common-files/etc/udev/rules.d"
  "$ROOT/common-files/etc/wireplumber/main.lua.d"
  "$ROOT/common-files/usr/bin"
  "$ROOT/common-files/usr/lib/systemd/system"
  "$ROOT/common-files/usr/share/justfiles"
  "$ROOT/common-files/default/grub.d"
  "$ROOT/templates"
  "$ROOT/variants/init-minimal/files"
  "$ROOT/scripts"
  "$ROOT/docs"
)

# Create directories
for dir in "${DIRS[@]}"; do
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    echo "Created: $dir"
  else
    echo "Exists:  $dir"
  fi
done
