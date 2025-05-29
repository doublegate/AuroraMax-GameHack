#!/usr/bin/env bash
# Direct build script for AuroraMax GameHack
# This script builds the image using podman directly to avoid BlueBuild's key mounting issue

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
bluebuild generate recipe.yml

# Fix the Containerfile by removing the problematic key mounting step
echo -e "${YELLOW}Fixing Containerfile...${NC}"

# Create a fixed version of the Containerfile
cp Containerfile Containerfile.fixed

# Remove the key mounting step entirely (lines containing stage-keys mount)
sed -i '/RUN --mount=type=bind,from=stage-keys/,/ostree container commit/d' Containerfile.fixed

# Also remove the empty stage-keys stage
sed -i '/FROM scratch AS stage-keys/,/^$/d' Containerfile.fixed

# Remove the content-based file creation from the files module JSON
# This is needed because BlueBuild has issues with content-based files
sed -i '66s/,{"content":"NAME=\\"AuroraMax GameHack\\"\\nVERSION=\\"1.0\\"\\nVARIANT=\\"init-minimal\\"\\nPRETTY_NAME=\\"AuroraMax GameHack 1.0 (Init-Minimal)\\"\\nHOME_URL=\\"https:\/\/github.com\/doublegate\/auroramax-gamehack\\"\\n","destination":"\/etc\/auroramax-release"}//g' Containerfile.fixed

echo -e "${YELLOW}Building image with podman...${NC}"

# Build using podman directly with the fixed Containerfile
# Stay in the variant directory for proper build context
if podman build -f Containerfile.fixed -t localhost/auroramax-gamehack-init-minimal:latest .; then
    echo -e "${GREEN}Build completed successfully!${NC}"
    
    # Show image info
    echo -e "\n${YELLOW}Built image:${NC}"
    podman images | grep "auroramax-gamehack-init-minimal" | head -1
    
    echo -e "\n${YELLOW}To run the container:${NC}"
    echo "podman run -it localhost/auroramax-gamehack-init-minimal:latest bash"
    
    echo -e "\n${YELLOW}To save as tar for distribution:${NC}"
    echo "podman save localhost/auroramax-gamehack-init-minimal:latest -o auroramax-init-minimal.tar"
    
    echo -e "\n${YELLOW}To tag for push to registry:${NC}"
    echo "podman tag localhost/auroramax-gamehack-init-minimal:latest ghcr.io/YOUR_ORG/auroramax-gamehack-init-minimal:latest"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi