#!/bin/bash
# AuroraMax GameHack BlueBuild Helper Script
# build-bluebuild.sh
#
# This script helps set up the directory structure and run BlueBuild
# to create the AuroraMax GameHack Init-Minimal variant

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="auroramax-gamehack"
VARIANT="init-minimal"
REGISTRY="${REGISTRY:-localhost}"
IMAGE_NAME="${IMAGE_NAME:-$PROJECT_NAME}"
IMAGE_TAG="${IMAGE_TAG:-$VARIANT-latest}"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

print_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Build AuroraMax GameHack using BlueBuild

Options:
    -h, --help              Show this help message
    -s, --setup             Set up the directory structure only
    -b, --build             Build the image (default)
    -p, --push              Push the image after building
    -r, --registry REGISTRY Registry to use (default: localhost)
    -t, --tag TAG           Image tag (default: init-minimal-latest)
    -c, --clean             Clean build artifacts before building

Example:
    $0 --setup              # Set up directory structure
    $0 --build              # Build the image
    $0 --build --push       # Build and push the image

EOF
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check for podman or docker
    if command -v podman &> /dev/null; then
        CONTAINER_TOOL="podman"
    elif command -v docker &> /dev/null; then
        CONTAINER_TOOL="docker"
    else
        log_error "Neither podman nor docker found. Please install one."
        exit 1
    fi
    log_success "Found container tool: $CONTAINER_TOOL"
    
    # Check for BlueBuild
    if ! command -v bluebuild &> /dev/null; then
        log_warning "BlueBuild not found. Installing..."
        install_bluebuild
    else
        log_success "BlueBuild is installed"
    fi
}

# Install BlueBuild
install_bluebuild() {
    log_info "Installing BlueBuild..."
    
    # Method 1: Using cargo (if available)
    if command -v cargo &> /dev/null; then
        cargo install blue-build
    # Method 2: Download binary
    else
        log_info "Downloading BlueBuild binary..."
        BLUEBUILD_VERSION="v0.8.0"  # Update as needed
        ARCH=$(uname -m)
        case $ARCH in
            x86_64) ARCH="x86_64" ;;
            aarch64) ARCH="aarch64" ;;
            *) log_error "Unsupported architecture: $ARCH"; exit 1 ;;
        esac
        
        wget -O /tmp/bluebuild.tar.gz \
            "https://github.com/blue-build/cli/releases/download/${BLUEBUILD_VERSION}/blue-build-${ARCH}-unknown-linux-gnu.tar.gz"
        
        tar -xzf /tmp/bluebuild.tar.gz -C /tmp
        sudo mv /tmp/bluebuild /usr/local/bin/
        sudo chmod +x /usr/local/bin/bluebuild
        rm -f /tmp/bluebuild.tar.gz
    fi
    
    log_success "BlueBuild installed successfully"
}

# Create directory structure
setup_directories() {
    log_info "Setting up directory structure..."
    
    # Create main directories
    mkdir -p common-files/{etc,usr}/{bin,lib/systemd/system,share/justfiles}
    mkdir -p common-files/etc/{sysctl.d,kernel/cmdline.d,modprobe.d,modules-load.d}
    mkdir -p common-files/etc/{environment.d,NetworkManager/conf.d,pulse/daemon.conf.d}
    mkdir -p common-files/etc/{security/limits.d,systemd,tmpfiles.d,udev/rules.d}
    mkdir -p common-files/etc/{wireplumber/main.lua.d,sysconfig,skel,motd.d}
    mkdir -p common-files/etc/{default/grub.d,systemd/journald.conf.d,systemd/logind.conf.d}
    mkdir -p common-files/etc/systemd/system
    
    log_success "Directory structure created"
    
    # Create placeholder message
    cat > common-files/README.md << 'EOF'
# AuroraMax GameHack Common Files

This directory contains all the configuration files that will be copied into the image.

## Directory Structure

- `etc/` - System configuration files
  - `sysctl.d/` - Kernel parameters
  - `udev/rules.d/` - Device rules
  - `systemd/` - Systemd configurations
  - `skel/` - User skeleton files (.bashrc, .bash_aliases)
  - And more...
  
- `usr/` - System binaries and data
  - `bin/` - Executable scripts
  - `lib/systemd/system/` - Systemd service files
  - `share/justfiles/` - Just command files

## Adding Files

Place the actual configuration files in their respective directories matching
the structure they should have in the final system.

For example:
- A sysctl config goes in `etc/sysctl.d/99-auroramax-base.conf`
- A udev rule goes in `etc/udev/rules.d/60-io-scheduler.rules`
EOF
    
    log_info "Created README.md with instructions"
}

# Clean build artifacts
clean_build() {
    log_info "Cleaning build artifacts..."
    
    # Remove BlueBuild cache
    rm -rf .bluebuild
    
    # Clean container images if requested
    if [[ "${DEEP_CLEAN:-false}" == "true" ]]; then
        log_warning "Performing deep clean (removing related images)..."
        $CONTAINER_TOOL rmi -f $(${CONTAINER_TOOL} images -q ${REGISTRY}/${IMAGE_NAME} 2>/dev/null) 2>/dev/null || true
    fi
    
    log_success "Clean completed"
}

# Build the image
build_image() {
    log_info "Building AuroraMax GameHack image..."
    log_info "Registry: $REGISTRY"
    log_info "Image: $IMAGE_NAME:$IMAGE_TAG"
    
    # Check if recipe.yml exists
    if [ ! -f "recipe.yml" ]; then
        log_error "recipe.yml not found in current directory"
        exit 1
    fi
    
    # Check if common-files directory exists
    if [ ! -d "common-files" ]; then
        log_error "common-files directory not found. Run with --setup first."
        exit 1
    fi
    
    # Set build arguments
    export IMAGE_NAME="$IMAGE_NAME"
    export IMAGE_TAG="$IMAGE_TAG"
    export BUILD_DATE=$(date -u +'%Y-%m-%d %H:%M:%S UTC')
    
    # Run BlueBuild
    log_info "Running BlueBuild..."
    bluebuild build \
        --recipe recipe.yml \
        --registry "$REGISTRY" \
        --image "$IMAGE_NAME" \
        --tag "$IMAGE_TAG"
    
    if [ $? -eq 0 ]; then
        log_success "Build completed successfully!"
        log_info "Image created: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    else
        log_error "Build failed!"
        exit 1
    fi
}

# Push the image
push_image() {
    log_info "Pushing image to registry..."
    
    $CONTAINER_TOOL push "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    
    if [ $? -eq 0 ]; then
        log_success "Push completed successfully!"
    else
        log_error "Push failed!"
        exit 1
    fi
}

# Test the image
test_image() {
    log_info "Testing the built image..."
    
    # Create a test script
    cat > /tmp/test-auroramax.sh << 'EOF'
#!/bin/bash
echo "Testing AuroraMax GameHack image..."
echo "=================================="
echo

# Check release file
if [ -f /etc/auroramax-release ]; then
    echo "Release information:"
    cat /etc/auroramax-release
    echo
else
    echo "ERROR: /etc/auroramax-release not found!"
fi

# Check if just is available
if command -v just &> /dev/null; then
    echo "✓ just command is available"
else
    echo "✗ just command not found"
fi

# Check for key directories
dirs=("/opt/auroramax" "/usr/share/justfiles" "/usr/share/auroramax")
for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "✓ Directory exists: $dir"
    else
        echo "✗ Directory missing: $dir"
    fi
done

# Check for key services
services=("auroramax-firstboot.service" "auroramax-performance.service")
for service in "${services[@]}"; do
    if [ -f "/usr/lib/systemd/system/$service" ]; then
        echo "✓ Service exists: $service"
    else
        echo "✗ Service missing: $service"
    fi
done

echo
echo "Test completed!"
EOF

    chmod +x /tmp/test-auroramax.sh
    
    # Run test in container
    $CONTAINER_TOOL run --rm -it \
        -v /tmp/test-auroramax.sh:/test.sh:ro \
        "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}" \
        /test.sh
    
    rm -f /tmp/test-auroramax.sh
}

# Main script
main() {
    local action="build"
    local push_after_build=false
    local clean_before_build=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                print_usage
                exit 0
                ;;
            -s|--setup)
                action="setup"
                shift
                ;;
            -b|--build)
                action="build"
                shift
                ;;
            -p|--push)
                push_after_build=true
                shift
                ;;
            -r|--registry)
                REGISTRY="$2"
                shift 2
                ;;
            -t|--tag)
                IMAGE_TAG="$2"
                shift 2
                ;;
            -c|--clean)
                clean_before_build=true
                shift
                ;;
            --test)
                action="test"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
    
    # Execute requested action
    case $action in
        setup)
            setup_directories
            log_success "Setup completed! Now add your configuration files to common-files/"
            ;;
        build)
            check_prerequisites
            if [[ "$clean_before_build" == "true" ]]; then
                clean_build
            fi
            build_image
            if [[ "$push_after_build" == "true" ]]; then
                push_image
            fi
            log_info "To test the image, run: $0 --test"
            ;;
        test)
            test_image
            ;;
    esac
}

# Run main function
main "$@"