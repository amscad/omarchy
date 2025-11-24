# Fork Workflow Guide

This document describes how to maintain and develop your personal fork of Omarchy while staying synchronized with the upstream repository.

## Overview

```
Upstream (basecamp/omarchy)
  └── master ────────────────┐
                             │
Your Fork (amscad/omarchy)   │
  ├── main ◄─────────────────┤ Tracks upstream/master
  │    └─ Pull from upstream when needed
  │    └─ Contains your customizations
  │
  ├── feature/your-feature ──┐
  │    └─ Branches FROM main │
  │    └─ Merges BACK TO main│
  │    └─ Stays on your fork │
  │
  └── [other branches]
```

## Repository Configuration

Your fork is configured with:

- **origin** = `https://github.com/amscad/omarchy.git` (your fork)
- **upstream** = `https://github.com/basecamp/omarchy.git` (original repo)

Your `main` branch tracks `upstream/master`, meaning updates from the original repository are automatically available to pull.

## Branches

### `main` (Your Customized Version)

- Tracks `upstream/master`
- Contains your custom additions:
  - Terminal compatibility improvements (Alacritty, Foot)
  - CLAUDE.md development guide
- Updated when:
  - You pull changes from upstream
  - You merge feature branches
- Pushed to: `origin/main` (your fork on GitHub)

### Feature Branches

- Pattern: `feature/descriptive-name`
- Created from: `main`
- Merged back to: `main` (not to upstream)
- Examples:
  - `feature/add-alacritty-foot-terminals` (in progress)
  - `feature/improve-theme-system`
  - `feature/custom-config`

### Branches NOT to Push

- `master` - avoid using, use `main` instead
- Old feature branches - clean them up when done

## Daily Workflow

### 1. Check Current Status

```bash
git status
git branch -vv        # See which branches track what
```

### 2. Update From Upstream (When Original Repo Updates)

When basecamp/omarchy releases updates:

```bash
# Make sure you're on main
git checkout main

# Pull latest from upstream
git pull              # Pulls from upstream/master (configured)

# Push to your fork to stay in sync
git push origin main
```

**What happens:**
- Your main stays synchronized with upstream/master
- Your customizations (terminal packages, CLAUDE.md) are preserved
- Git auto-merges upstream changes with your additions

### 3. Create a New Feature

```bash
# Start from main (always)
git checkout main

# Create feature branch
git checkout -b feature/your-feature-name

# Make your changes and commit
# (your commits here)

# Push to your fork
git push -u origin feature/your-feature-name
```

**Important:**
- Always branch FROM main
- Never push features to upstream
- Keep feature branches focused on one change

### 4. Finalize a Feature (Merge Into Main)

When your feature is tested and ready to keep:

```bash
# Switch to main
git checkout main

# Merge your feature
git merge feature/your-feature-name

# Push updated main to your fork
git push origin main

# Clean up the feature branch
git branch -d feature/your-feature-name                    # Local delete
git push origin --delete feature/your-feature-name        # Remote delete
```

### 5. Clean Up Old Branches

```bash
# List all branches (local and remote)
git branch -a

# Delete local branch
git branch -D feature/old-feature-name

# Delete remote branch
git push origin --delete feature/old-feature-name
```

## Common Tasks

### See What's Different From Upstream

```bash
# Commits you have that upstream doesn't
git log upstream/master..main

# Commits upstream has that you don't
git log main..upstream/master

# File differences
git diff upstream/master main
```

### Handle Merge Conflicts With Upstream

If pulling from upstream causes conflicts:

```bash
git checkout main
git pull                  # This might fail with conflicts

# Fix conflicts in your editor
# Then:
git add .
git commit -m "Resolve merge conflict with upstream"
git push origin main
```

### Revert a Feature

If you merged a feature and want to undo it:

```bash
git checkout main

# Option 1: Revert the merge commit
git revert -m 1 <commit-hash>
git push origin main

# Option 2: Reset to before the merge (loses commits)
git reset --hard <commit-before-merge>
git push -f origin main    # Force push after reset
```

### See Your Custom Changes

What you've added beyond upstream:

```bash
# See all your commits vs upstream
git log --oneline upstream/master..main

# See file changes vs upstream
git diff upstream/master main -- install/omarchy-base.packages
```

## Maintaining Your Fork

### Weekly Checklist

- [ ] Check if upstream/master has updates: `git fetch upstream`
- [ ] Pull if new commits: `git checkout main && git pull`
- [ ] Clean up old feature branches
- [ ] Ensure your main is stable

### Before Building ISO

Always verify your main branch is clean and up-to-date:

```bash
git checkout main
git status                    # Should be clean
git log --oneline -5          # Check recent commits
git diff upstream/master      # See your customizations
```

## Important Rules

**DO:**
- ✓ Branch from `main` for all features
- ✓ Merge features back into `main` when done
- ✓ Pull from `upstream` to stay synchronized
- ✓ Push to `origin` (your fork) regularly
- ✓ Keep feature branches focused and short-lived

**DON'T:**
- ✗ Push feature branches to upstream
- ✗ Click "Compare & pull request" to basecamp/omarchy
- ✗ Force push to `main` (unless recovering from mistakes)
- ✗ Commit directly to `main` for major features (use branches)
- ✗ Ignore merge conflicts (resolve them explicitly)

## Troubleshooting

### "I accidentally pushed to upstream"

If you somehow pushed a feature branch to basecamp/omarchy:

1. Go to https://github.com/basecamp/omarchy
2. Find the branch in the branch list
3. Click the delete button, or:

```bash
git push upstream --delete feature/accidentally-pushed
```

### "My main branch is behind upstream"

```bash
git checkout main
git pull              # This will catch you up
git push origin main
```

### "My main branch is ahead with commits I don't want"

Option 1: Reset to match upstream exactly

```bash
git checkout main
git reset --hard upstream/master
git push -f origin main
```

Option 2: Revert specific commits

```bash
git revert <commit-hash>
git push origin main
```

## Customizations in This Fork

Your `main` branch includes:

1. **Terminal Compatibility** (`install/omarchy-base.packages`)
   - Alacritty: GPU-accelerated terminal
   - Foot: Lightweight Wayland alternative
   - Purpose: Support older hardware without OpenGL context

2. **CLAUDE.md** (`CLAUDE.md`)
   - Development guide for Claude Code
   - Omarchy architecture documentation
   - Common commands and workflows

These customizations stay in your fork and don't affect upstream. If you want to contribute them back later, you can cherry-pick or create explicit PRs.

## Syncing With Upstream

### Monthly Update Strategy

```bash
# Check what's new
git fetch upstream
git log upstream/master..main    # Your changes
git log main..upstream/master    # Their changes

# Pull updates
git checkout main
git pull
git push origin main

# Rebuild ISO if needed
```

### Handling Major Upstream Changes

If upstream makes breaking changes:

```bash
# See what changed
git diff main upstream/master -- install/

# Manual merge if needed
git checkout main
git merge upstream/master
# Fix any conflicts manually
git push origin main
```

## Reference

### Branch Tracking

Check what each branch tracks:

```bash
git branch -vv
```

Output should show:
- `main` → `[upstream/master]`
- `feature/...` → `[origin/feature/...]`
- `master` → `[origin/master]`

### Remote Configuration

```bash
git remote -v
```

Should show:
- `origin` = your fork (fetch/push)
- `upstream` = original repo (fetch/push)

## Questions?

Refer to:
- `README.md` - Omarchy overview
- `CLAUDE.md` - Development environment setup
- `git help <command>` - Git documentation
