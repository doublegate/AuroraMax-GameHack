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

echo -e "${YELLOW}Generating Containerfile with BlueBuild...${NC}"

# Generate the Containerfile
cd variants/init-minimal

# Create a backup of the original Containerfile if present
if [[ -f Containerfile ]]; then
    cp Containerfile Containerfile.backup
fi

cleanup() {
    rm -rf keys
    if [[ -f Containerfile.backup ]]; then
        mv Containerfile.backup Containerfile
    fi
}
trap cleanup EXIT

bluebuild generate -o Containerfile recipe.yml

# Fix the stage-keys issue in the generated Containerfile
echo -e "${YELLOW}Fixing stage-keys in Containerfile...${NC}"

mkdir -p keys
cp ../../common-files/keys/cosign.pub keys/

# Fix the empty stage-keys by adding COPY command from build context
sed -i '/FROM scratch AS stage-keys/a COPY ./keys /keys' Containerfile

echo -e "${YELLOW}Building image...${NC}"

# Build the patched Containerfile with podman
if podman build -f Containerfile -t localhost/auroramax-gamehack-init-minimal:latest .; then
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