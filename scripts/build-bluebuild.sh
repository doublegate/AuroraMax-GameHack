#!/usr/bin/env bash
# Build script for AuroraMax GameHack using BlueBuild
# This script handles the key mounting issue with BlueBuild

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [[ ! -f "variants/init-minimal/recipe.yml" ]]; then
    echo -e "${RED}Error: Not in AuroraMax-GameHack root directory${NC}"
    echo "Please run this script from the project root"
    exit 1
fi

# Create a temporary directory for the build context
BUILD_DIR=$(mktemp -d)
trap "rm -rf $BUILD_DIR" EXIT

echo -e "${YELLOW}Setting up build context...${NC}"

# Copy the recipe file
cp variants/init-minimal/recipe.yml "$BUILD_DIR/"

# Create the files directory structure
mkdir -p "$BUILD_DIR/files/scripts"

# Copy pre and post scripts
cp variants/init-minimal/files/scripts/pre_script.sh "$BUILD_DIR/files/scripts/"
cp variants/init-minimal/files/scripts/post_script.sh "$BUILD_DIR/files/scripts/"

# Copy common files
cp -r common-files "$BUILD_DIR/"

# BlueBuild expects keys in a specific location
# Create a keys directory at the build context root
mkdir -p "$BUILD_DIR/keys"
cp common-files/keys/cosign.pub "$BUILD_DIR/keys/"

# Change to build directory
cd "$BUILD_DIR"

echo -e "${YELLOW}Running BlueBuild...${NC}"

# Run bluebuild with the recipe
if bluebuild build recipe.yml; then
    echo -e "${GREEN}Build completed successfully!${NC}"
    
    # Show image info
    echo -e "\n${YELLOW}Built image:${NC}"
    podman images | grep "auroramax-gamehack-init-minimal" | head -1
    
    echo -e "\n${YELLOW}To run the container:${NC}"
    echo "podman run -it localhost/auroramax-gamehack-init-minimal:latest bash"
    
    echo -e "\n${YELLOW}To build an ISO:${NC}"
    echo "bluebuild build-iso recipe.yml"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi