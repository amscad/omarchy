# Building Omarchy ISO

This guide explains how to build a custom Omarchy ISO with your fork's modifications using Docker on macOS (M1/Intel).

## Important Note

The Omarchy repository configuration files are in this repo, but the actual archiso build profile and ISO building infrastructure may be in a separate system. This guide provides two approaches:

1. **Docker-based build environment** (experimental)
2. **Using existing Omarchy installation** (recommended)

## Approach 1: Docker Build Environment (Experimental)

### Prerequisites

- Docker Desktop installed on macOS
- ~20GB free disk space
- ~30 minutes for initial build on M1 (x86_64 emulation takes time)

### Building with Docker

```bash
# From the omarchy repository root
./docker-build-iso.sh
```

This script will:
1. Check if Docker is installed
2. Build a Docker image with Arch Linux + archiso tools
3. Copy your fork into the build environment
4. Provide instructions for running the build

### Inside the Docker Container

```bash
# Start the build container (after running docker-build-iso.sh)
docker run --rm -it -v iso-output:/output omarchy-builder:latest

# Inside the container
cd /build/omarchy

# Attempt to find and run the build process
# This depends on whether archiso profile exists
ls -la                          # Explore the structure
find . -name "archiso" -type d  # Look for archiso profile
find . -name "build*.sh" -type f # Look for build scripts
```

### Issues You May Encounter

**Issue:** "No archiso profile found"
- **Cause:** The full ISO building system may be in a separate repository
- **Solution:** See "Approach 2" below

**Issue:** Build takes very long on M1
- **Cause:** Docker is emulating x86_64 architecture
- **Solution:** This is normal; let it run. Consider using a Linux system for faster builds.

**Issue:** Permission denied errors
- **Cause:** archiso requires root access
- **Solution:** Some steps may need `sudo` inside the container

## Approach 2: Using Existing Omarchy Installation (Recommended)

If you already have Omarchy running on your MacBook, you can:

### A. Test Changes Via Installation

Your fork's customizations (Alacritty, Foot, VSCode, webapp removals) are in `install/` and `config/` directories. Any Omarchy installation can pull your changes:

```bash
# On your MacBook running Omarchy
cd ~/.local/share/omarchy
git remote add fork https://github.com/amscad/omarchy.git
git fetch fork main
git merge fork/main

# Apply updates via migrations
# Restart for some changes to take effect
```

### B. Deploy Migrations for New Installs

Your changes are already reflected in your fork's `main` branch. When the official Omarchy releases a new ISO, it will include the latest packages from repositories. Your customizations live in:

- `install/omarchy-base.packages` - Package list
- `install/packaging/webapps.sh` - Web applications
- `config/` - Application configurations
- `migrations/` - Runtime changes for existing installs

### C. Request ISO Build from Omarchy Team

To get an official ISO built from your fork:

1. Create a Pull Request to `basecamp/omarchy` (if you want to contribute)
2. Or contact the Omarchy team at https://omarchy.org with:
   - Your fork URL (https://github.com/amscad/omarchy)
   - Brief description of customizations
   - Target hardware (Intel MacBook)

## Your Fork's Customizations

### Already in Your Fork

✓ **Alacritty** - GPU-accelerated terminal (configured)
✓ **Foot** - Lightweight Wayland terminal (configured)
✓ **VSCode** - Professional code editor
✓ **Removed** - 8 web apps, signal-desktop (communication/social bloat)
✓ **CLAUDE.md** - Development guide
✓ **FORK_WORKFLOW.md** - Git workflow documentation

These are in `install/omarchy-base.packages` and `install/packaging/webapps.sh`.

### How They're Deployed

**On New Installs:**
- Boot from ISO with your fork's packages
- Packages are installed during initial setup via `install/packaging/base.sh`

**On Existing Installs:**
- Create a migration file: `omarchy-dev-add-migration`
- Migration runs on next system update
- Changes apply without reinstallation

## Building for Your 2012 MacBook

Your 2012 MacBook Pro has:
- Intel i7 (not Apple Silicon)
- 16GB RAM
- Supports modern Arch Linux (x86_64)

### ISO Architecture

The ISO must be x86_64 (Intel). Building on M1 macOS requires:
- Docker with x86_64 emulation (slower but works)
- Or a native x86_64 Linux system (faster)
- Or cloud Linux instance (AWS t2.large, DigitalOcean)

### Performance Notes

- Docker x86_64 emulation: ~30+ minutes for first build on M1
- Native Arch Linux: ~10-15 minutes
- Subsequent builds (cached): ~5-10 minutes

## Testing Your Changes

### Before Building ISO

Test using your current Omarchy installation:

```bash
# Pull latest from your fork
cd ~/.local/share/omarchy
git fetch origin main
git merge origin/main

# Test new packages
pacman -S alacritty foot code
alacritty --version
foot --version
code --version

# Test removed apps aren't in menu
# Verify web apps are correct
```

### After Building ISO

Create bootable USB and test on your MacBook:

```bash
# On macOS with ISO file
# Write to USB (use Disk Utility or command line)
diskutil list                    # Find USB device
diskutil unmountDisk /dev/diskX
sudo dd if=omarchy.iso of=/dev/rdiskX bs=4m status=progress
```

## Troubleshooting

### Docker Build Fails

```bash
# Check Docker is running
docker ps

# Verify M1 compatibility
docker version

# Try building with more resources
docker run --cpus="2" --memory="8g" ...
```

### ISO Won't Boot on MacBook

1. Verify USB was written correctly
2. Use Command+Option+P+R to reset NVRAM on boot
3. May need to disable Secure Boot in firmware
4. Check that ISO is x86_64 (not ARM64)

### Packages Missing from ISO

Archiso pulls packages from Arch Linux repositories. Ensure:
- Package exists in AUR/official repos
- Dependencies are available
- No package conflicts

## File Structure for Build

```
omarchy/
├── Dockerfile.builder          # Docker image definition
├── docker-build-iso.sh         # Build script
├── install/                    # Installation system
│   ├── omarchy-base.packages   # Core packages (includes your changes)
│   ├── packaging/
│   │   └── webapps.sh          # Web apps (your removals here)
│   └── ...
├── config/                     # App configs
└── migrations/                 # Runtime changes
```

## Next Steps

1. **Immediate:** Test your customizations on existing install
   ```bash
   git fetch origin main
   git merge origin/main
   ```

2. **Short-term:** Create a Docker build environment
   ```bash
   ./docker-build-iso.sh
   ```

3. **Long-term:**
   - Contribute changes back to basecamp/omarchy if valuable
   - Maintain your fork with latest upstream updates
   - Use migrations for configuration changes

## References

- [Archiso Documentation](https://wiki.archlinux.org/title/Archiso)
- [Arch Linux Build System](https://wiki.archlinux.org/title/Makepkg)
- [Docker on macOS M1](https://docs.docker.com/desktop/install/mac-install/)
- [Omarchy - omarchy.org](https://omarchy.org)

## Support

For Omarchy-specific build questions:
- GitHub Issues: https://github.com/basecamp/omarchy/issues
- Omarchy Website: https://omarchy.org

For your fork customizations, refer to:
- `FORK_WORKFLOW.md` - Managing your fork
- `CLAUDE.md` - Development environment
