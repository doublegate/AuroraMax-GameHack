#!/bin/bash
set -euxo pipefail

# Enable Bazzite COPR repositories for custom kernel packages
dnf copr enable -y ublue-os/bazzite
dnf copr enable -y bazzite-org/kernel-bazzite

# Update package metadata
dnf makecache -y
