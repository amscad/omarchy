#!/bin/bash

# Docker-based ISO Builder for Omarchy
# Run this script to build an Omarchy ISO in Docker on macOS M1
# The resulting ISO will be suitable for Intel systems (including your 2012 MacBook Pro)

set -eEo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Omarchy ISO Builder for Intel MacBook${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found. Please install Docker Desktop for macOS.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker is installed${NC}"

# Create output directory
OUTPUT_DIR="${SCRIPT_DIR}/iso-output"
mkdir -p "$OUTPUT_DIR"
echo -e "${GREEN}✓ Output directory: $OUTPUT_DIR${NC}"

echo ""
echo -e "${YELLOW}Building Docker image...${NC}"
echo "This may take a few minutes on M1 Mac (building x86_64 image)"
echo ""

# Build the Docker image
docker build \
    --platform linux/x86_64 \
    -f "$SCRIPT_DIR/Dockerfile.builder" \
    -t omarchy-builder:latest \
    "$SCRIPT_DIR"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Docker image built successfully${NC}"
else
    echo -e "${RED}✗ Docker image build failed${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Build environment ready!${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Start a bash session in the build container:"
echo "   docker run --rm -it -v $OUTPUT_DIR:/output omarchy-builder:latest"
echo ""
echo "2. Inside the container:"
echo "   cd /build/omarchy"
echo "   # Check if there's a build script or archiso profile"
echo "   ls -la"
echo ""
echo "3. Build the ISO (exact command depends on Omarchy build system)"
echo "   # May need to run: mkarchiso -v -o /output ."
echo "   # Or check for a build.sh script"
echo ""
echo "4. The ISO will be saved to: $OUTPUT_DIR"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "The actual ISO building process requires the archiso profile"
echo "from the Omarchy project. The repository may need additional"
echo "setup steps that are documented elsewhere."
echo ""

echo -e "${GREEN}ℹ  Docker image details:${NC}"
docker image inspect omarchy-builder:latest | grep -E "Architecture|Os" | head -2

echo ""
echo -e "${YELLOW}To remove the Docker image when done:${NC}"
echo "docker rmi omarchy-builder:latest"
