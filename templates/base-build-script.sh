#!/usr/bin/env bash

set -euo pipefail

# CONFIGURATION
RECIPE="recipe.yml"
IMAGE_NAME="auroramax-gamehack"
GHCR_USERNAME="doublegate"
TAG="latest"
FULL_TAG="ghcr.io/${GHCR_USERNAME}/${IMAGE_NAME}:${TAG}"

# INIT: Ensure cosign image is locally available for podman multi-stage build
echo "📥 Pre-pulling cosign image for Podman compatibility..."
podman pull ghcr.io/sigstore/cosign/cosign:v2.4.3

# STEP 1: Generate the Containerfile
echo "🛠️  Generating Containerfile from ${RECIPE}..."
bluebuild generate -o Containerfile "$RECIPE"

# STEP 2: Build with Podman
echo "📦 Building container image with podman..."
podman build -t "${IMAGE_NAME}" -f Containerfile .

# STEP 3: Test run (optional interactive shell)
echo "🧪 Running container for testing..."
podman run -it --rm "${IMAGE_NAME}" /bin/bash || echo "🔍 Container exited or no shell available"

# STEP 4: Tag the image for GHCR
echo "🏷️  Tagging image for GHCR..."
podman tag "${IMAGE_NAME}" "${FULL_TAG}"

# STEP 5: Login to GHCR (prompt for password if not already logged in)
echo "🔐 Logging into GitHub Container Registry (ghcr.io)..."
podman login ghcr.io

# STEP 6: Push to GHCR
echo "🚀 Pushing image to ${FULL_TAG}..."
podman push "${FULL_TAG}"

echo "✅ Done! Image pushed to ${FULL_TAG}"
