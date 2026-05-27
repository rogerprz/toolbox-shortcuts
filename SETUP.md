# Mac Development Environment Setup

Automated bootstrap script to set up a new Mac with all development tools and configurations.

## Quick Start

Run this on a fresh Mac:

```bash
curl -fsSL https://raw.githubusercontent.com/rogerprz/toolbox-shortcuts/master/setup.sh | bash
```

Or if you already have the repo cloned:

```bash
cd toolbox-shortcuts
chmod +x setup.sh
./setup.sh
```

## What the Script Does

### 1. **Homebrew** 
   - Package manager for macOS
   - Installs if not already present

### 2. **Zsh & Oh My Zsh**
   - Modern shell with plugin support
   - Sets Zsh as default shell
   - Installs Oh My Zsh framework

### 3. **Zsh Plugins**
   - `zsh-autosuggestions` - Command suggestions as you type
   - `zsh-syntax-highlighting` - Color syntax highlighting

### 4. **Node Version Manager (NVM)**
   - Manage multiple Node.js versions
   - Allows switching between projects with different Node versions

### 5. **Development Tools**
   - `fzf` - Fuzzy finder for command history and files
   - `bat` - Better `cat` with syntax highlighting
   - `eza` - Better `ls` with colors and icons
   - `ripgrep` - Faster `grep` (rg command)
   - `tldr` - Simplified man pages
   - `gh` - GitHub CLI
   - `httpie` - Friendly curl alternative

### 6. **Nerd Font**
   - Meslo LG Nerd Font for terminal icons
   - Required for agnoster theme to display correctly

### 7. **Configuration Files**
   - `.zshrc` - Shell configuration with aliases and environment variables
   - `aliases.zsh` - Organized alias definitions
   - Optional: `.gitconfig` - Git configuration

## Features

✅ **Error Handling** - Gracefully handles failures and continues where possible
✅ **Idempotent** - Safe to run multiple times
✅ **Color Output** - Clear, easy-to-read status messages
✅ **Backups** - Creates `.zshrc.backup` if one already exists
✅ **Smart Checks** - Only installs what's not already present

## After Setup

### 1. Restart Your Terminal
```bash
exec zsh
```

### 2. Set Up SSH Key for GitHub
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub  # Copy this to GitHub
```

### 3. Add SSH Key to GitHub
- Go to https://github.com/settings/keys
- Click "New SSH key"
- Paste your public key

### 4. Verify Everything Works
```bash
ssh -T git@github.com  # Should show "Hi username!"
node --version         # Verify Node is installed
npm --version         # Verify npm is installed
```

## Useful Aliases

```bash
# Navigation
..          # cd ..
...         # cd ../..
1-5         # cd up 1-5 levels

# NPM
ni          # npm install
ns          # npm start
nt          # npm test
nrd         # npm run dev
nrb         # npm run build

# Git
g           # git
ga          # git add
gst         # git status
gc          # git commit
glog        # git log (pretty format)

# Utilities
reload      # Reload zsh configuration
aliases     # Edit your aliases
```

## Terminal Font Setup

The script installs **Meslo LG Nerd Font**. Set it in your terminal:

### iTerm2
1. iTerm2 → Settings → Profiles → Text
2. Set Font to "MesloLGS NF"

### VS Code
1. Settings → Terminal › Integrated: Font Family
2. Set to `MesloLGS NF`

## Troubleshooting

### "Command not found" after setup
```bash
exec zsh  # Restart your shell
```

### fzf keybindings not working
```bash
$(brew --prefix)/opt/fzf/install --all
```

### Zsh still not default shell
```bash
chsh -s $(which zsh)
```

### Need to reinstall everything
```bash
./setup.sh  # Safe to run again
```

## Backing Up Existing Config

If you have an existing `.zshrc`, the script will create a backup:
```bash
~/.zshrc.backup  # Your original config
```

You can merge manually if needed.

## Customization

Edit the setup script to add your own:
- Additional tools
- Custom aliases
- Git configuration
- IDE/editor setup

## Files in This Repo

- `setup.sh` - Main bootstrap script
- `.zshrc.template` - Template for zsh configuration
- `alias_for_bashrc` - Legacy bash aliases (for reference)
- `.gitconfig` - Example git configuration

## Support

If something fails:
1. Check error message (marked with ❌)
2. Try running the specific command manually
3. Check tool documentation
4. Run `./setup.sh` again (it's safe)

---

**Last Updated**: 2024
**Tested on**: macOS 13+