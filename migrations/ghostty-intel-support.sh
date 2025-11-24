#!/bin/bash
# Ghostty Intel GPU Support Setup
# Configures OpenGL and GPU drivers for Ghostty on Intel MacBooks

set -e

echo "Setting up Ghostty support for Intel GPUs..."

# Ensure Intel GPU packages are installed
echo "Installing Intel GPU driver packages..."
sudo pacman -Sy --needed \
    libva-intel-driver \
    intel-media-driver \
    intel-gmmlib \
    lib32-libva-intel-driver \
    vulkan-intel \
    lib32-mesa

# Set environment variables for Ghostty OpenGL support
mkdir -p ~/.config/ghostty

# Create/update configuration with OpenGL hints
if [ -f ~/.config/ghostty/config ]; then
    # Backup existing config
    cp ~/.config/ghostty/config ~/.config/ghostty/config.backup
fi

# Add OpenGL-related environment variables
cat >> ~/.config/environment.d/ghostty-opengl.conf <<'EOF'
# Intel GPU OpenGL support for Ghostty
export LIBVA_DRIVER_NAME=i965
export MESA_LOADER_DRIVER_OVERRIDE=i965
export GALLIUM_DRIVER=iris
export INTEL_DEBUG=
EOF

echo "GPU environment configured in ~/.config/environment.d/ghostty-opengl.conf"

# Verify OpenGL support
echo ""
echo "Checking OpenGL support..."
if command -v glxinfo &> /dev/null; then
    glxinfo | grep -E "OpenGL version|Vendor|Renderer" || echo "Warning: Could not verify OpenGL"
else
    echo "Installing mesa-utils for OpenGL verification..."
    sudo pacman -S --needed mesa-utils
    glxinfo | grep -E "OpenGL version|Vendor|Renderer" || echo "Warning: Could not verify OpenGL"
fi

echo ""
echo "✓ Intel GPU support configured"
echo ""
echo "Next steps:"
echo "1. Reload environment: exec \$SHELL"
echo "2. Restart Ghostty: ghostty"
echo ""
echo "If Ghostty still fails:"
echo "- Try Alacritty or Foot as alternatives"
echo "- Check: LIBVA_DRIVER_NAME=i965 glxinfo"
echo "- Report issue with: inxi -Gxx"
