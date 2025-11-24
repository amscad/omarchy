# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Omarchy is a beautiful, modern, and opinionated Linux distribution built on Arch Linux. It provides preconfigured environments with themes, development tools, and system customizations. The project is maintained by DHH and released under MIT License.

**Key URLs**: [omarchy.org](https://omarchy.org) | [GitHub](https://github.com/basecamp/omarchy)

## Repository Structure

### Core Directories

- **`bin/`** - Executable shell scripts (138 scripts, 4750+ lines total)
  - Commands prefixed with `omarchy-cmd-*` for user-facing functionality
  - Commands prefixed with `omarchy-dev-*` for development tooling
  - Commands prefixed with `omarchy-*` for system utilities
  - Each script is standalone and typically performs a single responsibility

- **`install/`** - Installation system sourced during setup
  - `helpers/` - Shared utility functions for installation scripts
  - `preflight/` - Pre-installation checks and system validation
  - `packaging/` - Package management (base, fonts, nvim, webapps, etc.)
  - `config/` - Configuration deployment during installation
  - `login/` - Login shell configuration
  - `post-install/` - Post-installation setup and first-run activities
  - `first-run/` - First-run initialization scripts
  - `*.packages` - Package lists (base packages, optional packages)

- **`migrations/`** - Timestamped migration scripts (200+ migrations)
  - Each migration is named by Unix timestamp (e.g., `1751134560.sh`)
  - Executed sequentially during system updates
  - Used to modify configuration, apply patches, or clean up old packages
  - Created with `omarchy-dev-add-migration` command

- **`config/`** - User configuration templates deployed to `~/.config`
  - Supports multiple tools: alacritty, kitty, ghostty, nvim, git, hypr, etc.
  - Configuration is copied to user directories during installation
  - Each app has its own subdirectory with config files

- **`default/`** - System-wide default configurations
  - Deployed to system locations (not user home directories)
  - Used for default packages, paths, and system-level configs

- **`themes/`** - VSCode and application themes (10+ themes available)
  - Each theme contains `vscode.json` for VS Code color scheme
  - Named after popular themes: gruvbox, nord, rose-pine, tokyo-night, etc.

- **`applications/`** - Desktop application definitions and metadata

- **`autostart/`** - Autostart applications and services

## Development Workflow

### Adding a New Migration

The standard way to make changes to the distribution is through migrations:

```bash
omarchy-dev-add-migration
```

This opens `nvim` with a new timestamped migration file. Migrations are shell scripts that:
- Run on existing Omarchy installations during updates
- Are idempotent (safe to run multiple times)
- Should contain `set -e` to exit on errors
- Execute in sequence by timestamp

Example migration purposes:
- Remove old packages: `pacman -R old-package`
- Update configuration files
- Deploy new config to `~/.config` or system paths
- Clean up deprecated settings
- Apply system-wide patches

### Installation System Flow

When Omarchy is installed, `install.sh` sources and executes:

1. **helpers/all.sh** - Load common utility functions
2. **preflight/all.sh** - System validation and checks
3. **packaging/all.sh** - Install packages using pacman/AUR
4. **config/all.sh** - Deploy user configurations
5. **login/all.sh** - Configure login shell
6. **post-install/all.sh** - Final setup and first-run initialization

Key environment variables (set in `install.sh`):
- `$OMARCHY_PATH` - Installation directory (`~/.local/share/omarchy`)
- `$OMARCHY_INSTALL` - Install scripts directory
- `$OMARCHY_INSTALL_LOG_FILE` - `/var/log/omarchy-install.log`
- `$PATH` - Prepends `$OMARCHY_PATH/bin` for command availability

### Bootstrapping

- **boot.sh** - Online installation entry point (used for curl installations)
  - Downloads Omarchy, optionally checks out specific branch via `OMARCHY_REF` env var
  - Supports custom repos via `OMARCHY_REPO` env var (default: basecamp/omarchy)
  - Sources `install.sh` to run installation

- **install.sh** - Local installation orchestrator
  - Sets up paths and environment
  - Sources all install modules
  - Logs to `/var/log/omarchy-install.log`

## Common Commands and Tasks

### User-Facing Commands

Most `omarchy-cmd-*` scripts provide system functionality:

```bash
omarchy-cmd-screenshot        # Take screenshots with options
omarchy-cmd-screenrecord      # Record video/screen
omarchy-cmd-audio-switch      # Switch audio outputs
omarchy-cmd-first-run         # Execute first-run setup
omarchy-cmd-screensaver       # Control screensaver
omarchy-battery-monitor       # Monitor battery status
omarchy-debug                 # Generate system debug report
```

### Debugging and System Information

```bash
# Generate comprehensive debug report (saved to /tmp/omarchy-debug.log)
omarchy-debug

# Check system status and logs
journalctl -b                 # Current boot logs
sudo dmesg                    # Kernel messages
inxi -Farz                    # Full system information
```

### Package Management

Package lists are defined in `install/`:
- `omarchy-base.packages` - Core packages (always installed)
- `omarchy-other.packages` - Optional packages
- `packages.ignored` - Packages to exclude
- `packages.pinned` - Packages to pin at specific versions

Packages are installed during `install/packaging/all.sh` which calls component installers:
- `base.sh` - Core Arch packages
- `fonts.sh` - Font packages
- `icons.sh` - Icon themes
- `nvim.sh` - Neovim and plugins
- `tuis.sh` - Terminal user interfaces
- `webapps.sh` - Web applications

### Configuration Deployment

Configurations are deployed from `config/` directory during installation:
- Files are copied to user's `~/.config` locations
- Each application has its config subdirectory
- Configurations are applied after package installation

## Architecture Patterns

### Shell Script Organization

All scripts follow consistent patterns:

1. **Error handling**: `set -eEo pipefail` for strict error mode
2. **Path setup**: Source helper functions from `install/helpers/`
3. **Logging**: Direct to stdout or `/var/log/omarchy-install.log`
4. **Idempotency**: Safe to run multiple times (use checks before modifications)
5. **Modular sourcing**: Install system uses `source` to load components

### Migration System Design

Migrations provide safe, traceable updates:
- Each migration is independent and timestamped
- They're stored in version control for audit trail
- Executed sequentially on existing systems
- Should be small, focused changes (one change per migration)
- Essential for distributing updates across user base

### Installation Module Architecture

Install modules are sourced in dependency order:
- **helpers** first (utilities needed by all)
- **preflight** checks system readiness
- **packaging** installs software
- **config** deploys user configs
- **post-install** runs final setup

Each module's `all.sh` sources its sub-modules in order.

## Key Development Considerations

### Making Changes

1. **For configuration changes**: Create a migration or edit config files
2. **For new packages**: Update package lists in `install/`
3. **For new commands**: Add script to `bin/` with appropriate prefix
4. **For first-run changes**: Edit `install/first-run/` scripts
5. **For installation logic**: Modify appropriate `install/` subdirectory

### Testing Changes

- Test migrations on a running Omarchy instance
- Verify install flow in clean VM/environment
- Check that scripts are executable (`chmod +x`)
- Validate bash syntax with `bash -n script.sh`
- Use `set -e` and proper error handling for safety

### Version Control

- Migrations are committed immediately (immutable history)
- Multiple changes in `bin/` can be committed together
- Config file changes track in git for audit trail
- Each migration commit should have clear message about the change

## Important Notes

- The distribution defaults to **Arch Linux** as base
- Installation paths: `~/.local/share/omarchy` for installation, `~/.config` for user configs
- System uses **Pacman** for package management and supports **AUR**
- Omarchy provides themed environments with preconfigured tools (Hyprland, Neovim, terminals, etc.)
- First-run setup includes DNS, firewall, battery monitoring, and theme configuration
- The project supports custom branches and repositories via environment variables during installation
