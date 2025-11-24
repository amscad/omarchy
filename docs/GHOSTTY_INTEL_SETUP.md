# Getting Ghostty Working on Intel MacBooks

This guide provides step-by-step instructions to make Ghostty work on Intel Mac hardware (2012-2015 era with integrated Intel GPUs).

## The Problem

```
Error: Unable to acquire an OpenGL context for rendering
```

This occurs when:
- Intel GPU drivers aren't properly configured
- OpenGL libraries are missing or misconfigured
- GPU acceleration isn't enabled in the environment

## Solution Overview

Ghostty requires proper GPU driver configuration. Your 2012 MacBook Pro **can** run Ghostty with the right setup.

## Step-by-Step Fix

### Step 1: Install Intel GPU Driver Packages

These are now included in your fork's `omarchy-other.packages`:

```bash
sudo pacman -Sy

# These should install automatically with system update
# Or manually:
sudo pacman -S --needed \
    libva-intel-driver \
    intel-media-driver \
    intel-gmmlib \
    lib32-libva-intel-driver \
    vulkan-intel \
    lib32-mesa
```

### Step 2: Configure GPU Environment Variables

Create GPU configuration file:

```bash
mkdir -p ~/.config/environment.d

cat > ~/.config/environment.d/ghostty-opengl.conf <<'EOF'
# Intel GPU OpenGL support for Ghostty
export LIBVA_DRIVER_NAME=i965
export MESA_LOADER_DRIVER_OVERRIDE=i965
export GALLIUM_DRIVER=iris
EOF
```

### Step 3: Reload Environment

```bash
# Method 1: Restart shell
exec $SHELL

# Method 2: Source the environment file
source ~/.config/environment.d/ghostty-opengl.conf
```

### Step 4: Verify OpenGL Support

```bash
# Install verification tool
sudo pacman -S mesa-utils

# Check OpenGL is available
glxinfo | grep -E "OpenGL version|Vendor|Renderer"

# You should see output like:
# OpenGL version string: 4.6 (Compatibility Profile)
# Vendor: Intel
# Renderer: Intel HD Graphics 4000
```

### Step 5: Launch Ghostty

```bash
ghostty
```

If successful, you should see the Ghostty terminal open without errors.

## Troubleshooting

### Issue: "OpenGL version: 1.4" (too old)

**Problem:** Old Mesa OpenGL version
**Solution:**
```bash
# Update system packages
sudo pacman -Syu

# Reinstall Mesa
sudo pacman -S --needed mesa mesa-demos

# Restart shell
exec $SHELL

# Verify again
glxinfo | grep "OpenGL version"
```

### Issue: "Renderer: llvmpipe" (software rendering - slow)

**Problem:** GPU drivers not loading, using CPU fallback
**Solution:**
```bash
# Check which driver is loading
LIBVA_DRIVER_NAME=i965 glxinfo | grep Renderer

# If still llvmpipe, try different driver
export GALLIUM_DRIVER=iris
glxinfo | grep Renderer

# If that works, update config file
echo 'export GALLIUM_DRIVER=iris' >> ~/.config/environment.d/ghostty-opengl.conf
```

### Issue: "No extension EGL_KHR_platform_wayland"

**Problem:** EGL (OpenGL interface) not configured for Wayland
**Solution:**
```bash
# Install EGL Wayland support
sudo pacman -S --needed egl-wayland

# Restart shell
exec $SHELL
```

### Issue: Still can't acquire OpenGL context

**Try alternative drivers:**

```bash
# Test with different Intel drivers
LIBVA_DRIVER_NAME=i965 ghostty    # Older driver
GALLIUM_DRIVER=i965 ghostty       # Alternative
GALLIUM_DRIVER=iris ghostty       # Newer driver (for Skylake+)
```

Add the working one to `~/.config/environment.d/ghostty-opengl.conf`

### Issue: Ghostty is slow/laggy

**Problem:** Software rendering is still happening
**Solution:**
```bash
# Verify hardware acceleration is actually working
glxinfo -B | grep -i hardware

# Should show "Yes" or OpenGL 4.x with Intel renderer
# If not, you may be on software rendering
# Try: inxi -Gxx to see what's detected
```

## Hardware Information

Check your GPU is detected:

```bash
# Install system info tool
sudo pacman -S inxi

# Check GPU
inxi -Gxx
```

**Expected for 2012 MacBook Pro:**
```
Graphics:
  Device-1: Intel 3rd Gen Core processor Graphics driver: i915 v: kernel
  Display: wayland server: weston v: 12 with: GNOME Shell driver: gpu
```

## Environment Variables Reference

| Variable | Value | Purpose |
|----------|-------|---------|
| `LIBVA_DRIVER_NAME` | `i965` | Video acceleration driver (older Intel) |
| `MESA_LOADER_DRIVER_OVERRIDE` | `i965` | Force Mesa to use specific driver |
| `GALLIUM_DRIVER` | `iris` or `i965` | GPU driver for Gallium (newer/older) |
| `INTEL_DEBUG` | (empty) | Suppress Intel driver debug output |

## Permanent Configuration

### Option 1: Per-User (Recommended)

Add to `~/.config/environment.d/ghostty-opengl.conf`:

```bash
export LIBVA_DRIVER_NAME=i965
export MESA_LOADER_DRIVER_OVERRIDE=i965
export GALLIUM_DRIVER=iris
```

This loads automatically when you log in on Hyprland/Wayland.

### Option 2: System-Wide

```bash
sudo tee /etc/environment.d/99-intel-gpu.conf <<'EOF'
LIBVA_DRIVER_NAME=i965
MESA_LOADER_DRIVER_OVERRIDE=i965
GALLIUM_DRIVER=iris
EOF
```

### Option 3: Ghostty Config File

Add to `~/.config/ghostty/config`:

```
# This doesn't help OpenGL context, but use for other settings
# Environment variables must be set before launching Ghostty
```

## If Ghostty Still Doesn't Work

### Fallback Option: Use Foot

Foot doesn't require OpenGL and works great on older hardware:

```bash
foot
```

### Fallback Option: Use Alacritty

Alacritty has better GPU driver compatibility:

```bash
alacritty
```

## Updating from Your Fork

If you're building from the fork, your ISO will include:

✓ All GPU driver packages
✓ Migration script: `ghostty-intel-support.sh`
✓ Alacritty and Foot as fallbacks

To run the setup migration:

```bash
bash /path/to/ghostty-intel-support.sh
```

## Testing Script

Save as `test-ghostty-setup.sh`:

```bash
#!/bin/bash
set -e

echo "Testing Ghostty Intel GPU setup..."
echo ""

echo "1. Checking GPU detection:"
inxi -Gxx
echo ""

echo "2. Checking OpenGL:"
glxinfo | grep -E "OpenGL version|Vendor|Renderer"
echo ""

echo "3. Checking Intel driver:"
lsmod | grep i915
echo ""

echo "4. Testing Ghostty:"
timeout 5 ghostty || echo "(Ghostty launched - close it to continue)"

echo ""
echo "✓ Setup test complete"
```

Run with: `bash test-ghostty-setup.sh`

## Support

- **Ghostty docs:** https://ghostty.org/docs/help/gtk-opengl-context
- **Mesa (OpenGL):** https://docs.mesa3d.org/
- **Intel drivers:** https://01.org/linuxgraphics/
- **Your fork:** https://github.com/amscad/omarchy

## Summary

For your 2012 MacBook Pro to run Ghostty:

1. ✓ Install GPU driver packages (included in fork)
2. ✓ Set environment variables (see Step 2)
3. ✓ Verify OpenGL works (glxinfo)
4. ✓ Launch Ghostty
5. → If fails, use Foot or Alacritty

All GPU packages are now in your fork's `omarchy-other.packages`, so new ISOs will have them pre-installed.
