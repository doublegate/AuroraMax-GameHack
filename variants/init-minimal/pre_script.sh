#!/bin/bash
set -euxo pipefail

# Enable Bazzite COPR repositories for custom kernel packages
dnf copr enable -y kylegospo/bazzite
dnf copr enable -y kylegospo/bazzite-multilib

# Update package metadata
dnf makecache -y
