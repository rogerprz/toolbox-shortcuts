#!/bin/bash

set -euo pipefail
RAW_BASE="https://raw.githubusercontent.com/rogerprz/toolbox-shortcuts/master"
SETUP_TEMP_DIR=""
trap 'if [ -n "$SETUP_TEMP_DIR" ]; then rm -rf "$SETUP_TEMP_DIR"; fi' EXIT
if [ -n "${BASH_SOURCE[0]:-}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    # A piped script has no source directory; fetch companion files on demand.
    SETUP_TEMP_DIR="$(mktemp -d)"
    SCRIPT_DIR="$SETUP_TEMP_DIR"
fi

ensure_file() {
    local relative_path="$1"
    if [ ! -f "$SCRIPT_DIR/$relative_path" ]; then
        mkdir -p "$(dirname "$SCRIPT_DIR/$relative_path")"
        curl -fsSL "$RAW_BASE/$relative_path" -o "$SCRIPT_DIR/$relative_path"
    fi
}

echo "🚀 Setting up new Mac..."

# Find Homebrew even when a fresh installation is not on PATH yet.
if ! command -v brew >/dev/null 2>&1; then
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brew_bin" ]; then
            eval "$("$brew_bin" shellenv)"
            break
        fi
    done
fi
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    # Download separately so a curl failure cannot be hidden by bash -c.
    if [ -z "$SETUP_TEMP_DIR" ]; then
        SETUP_TEMP_DIR="$(mktemp -d)"
    fi
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$SETUP_TEMP_DIR/homebrew-install.sh"
    if [ -t 0 ]; then
        /bin/bash "$SETUP_TEMP_DIR/homebrew-install.sh"
    elif ( : </dev/tty ) 2>/dev/null; then
        /bin/bash "$SETUP_TEMP_DIR/homebrew-install.sh" </dev/tty
    else
        echo "Homebrew needs an interactive terminal for administrator authentication. Download setup.sh and run it with bash in Terminal." >&2
        exit 1
    fi
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

app_present() {
    local app_name
    for app_name in "$@"; do
        if [ -d "/Applications/$app_name" ] || [ -d "$HOME/Applications/$app_name" ]; then
            return 0
        fi
    done
    return 1
}

install_formula() {
    local formula="$1" command_name="${2:-$1}"
    if brew list --formula "$formula" >/dev/null 2>&1 || { [ "$command_name" != "brew-only" ] && command -v "$command_name" >/dev/null 2>&1; }; then
        echo "Skipping $formula (already installed)."
    elif ! brew install "$formula"; then
        echo "Skipping $formula after Homebrew install failed; continuing setup." >&2
        return 0
    fi
}

install_cask() {
    local cask="$1"
    shift
    if app_present "$@" || brew list --cask "$cask" >/dev/null 2>&1; then
        echo "Skipping $cask (already installed)."
    elif ! brew install --cask "$cask"; then
        echo "Skipping $cask after Homebrew install failed; continuing setup." >&2
        return 0
    fi
}

# Use a local tap for the requested legacy versions, not today's Alfred/Snagit.
install_legacy_cask() {
    local cask="$1" tap_dir
    shift
    if app_present "$@" || brew list --cask "$cask" >/dev/null 2>&1; then
        echo "Skipping $cask (already installed)."
        return
    fi
    if ! brew tap | /usr/bin/grep -qx "toolbox-shortcuts/legacy"; then
        if ! brew tap-new toolbox-shortcuts/legacy; then
            echo "Skipping $cask: couldn't create the Homebrew tap; continuing setup." >&2
            return 0
        fi
    fi
    if ! tap_dir="$(brew --repository toolbox-shortcuts/legacy)"; then
        echo "Skipping $cask: couldn't locate the Homebrew tap; continuing setup." >&2
        return 0
    fi
    mkdir -p "$tap_dir/Casks"
    if ! ensure_file "Casks/$cask.rb" || ! cp "$SCRIPT_DIR/Casks/$cask.rb" "$tap_dir/Casks/$cask.rb"; then
        echo "Skipping $cask: couldn't prepare its Homebrew cask; continuing setup." >&2
        return 0
    fi
    if ! brew install --cask "toolbox-shortcuts/legacy/$cask"; then
        echo "Skipping $cask after Homebrew install failed; continuing setup." >&2
        return 0
    fi
}

install_formula node
install_formula python brew-only
# Install Homebrew tools before Xcode, whose download or license step can be skipped.
install_formula git brew-only
install_formula zsh
install_formula nvm
install_formula fzf
install_formula bat
install_formula eza
install_formula ripgrep
install_formula tldr
install_formula gh
install_formula httpie
install_cask visual-studio-code "Visual Studio Code.app"
install_cask google-chrome "Google Chrome.app"
if app_present "Google Chrome.app" || brew list --cask google-chrome >/dev/null 2>&1; then
    install_formula defaultbrowser
    if command -v defaultbrowser >/dev/null 2>&1; then
        if ! defaultbrowser chrome; then
            echo "Skipping Chrome default-browser setting; macOS did not accept the change." >&2
        fi
    else
        echo "Skipping Chrome default-browser setting: defaultbrowser is unavailable." >&2
    fi
else
    echo "Skipping Chrome default-browser setting because Chrome isn't installed." >&2
fi
install_cask chatgpt "ChatGPT.app"
install_cask claude "Claude.app"
install_cask iterm2 "iTerm.app" "iTerm2.app"
install_legacy_cask alfred3 "Alfred 3.app" "Alfred 4.app" "Alfred 5.app" "Alfred 6.app" "Alfred.app"
install_legacy_cask snagit22 "Snagit 2022.app" "Snagit.app" "Snagit 2023.app" "Snagit 2024.app" "Snagit 2025.app" "Snagit 2026.app"

# Query Apple's current release instead of pinning an Xcode version.
install_latest_xcode() {
    local metadata latest_version minimum_macos current_macos
    if [ -z "$SETUP_TEMP_DIR" ]; then
        SETUP_TEMP_DIR="$(mktemp -d)"
    fi
    metadata="$SETUP_TEMP_DIR/xcode.json"
    if ! curl -fsSL "https://itunes.apple.com/lookup?id=497799835&country=us" -o "$metadata"; then
        echo "Skipping Xcode: couldn't check the latest App Store version."
        return 0
    fi
    if ! latest_version="$(/usr/bin/plutil -extract results.0.version raw -o - "$metadata")" ||
       ! minimum_macos="$(/usr/bin/plutil -extract results.0.minimumOsVersion raw -o - "$metadata")"; then
        echo "Skipping Xcode: couldn't read the latest App Store version."
        return 0
    fi
    current_macos="$(sw_vers -productVersion)"
    if ! /usr/bin/awk -v current="$current_macos" -v minimum="$minimum_macos" 'BEGIN {
        split(current, c, "."); split(minimum, m, ".");
        for (i = 1; i <= 3; i++) {
            if (c[i] + 0 > m[i] + 0) exit 0;
            if (c[i] + 0 < m[i] + 0) exit 1;
        }
        exit 0;
    }'; then
        echo "Xcode $latest_version requires macOS $minimum_macos or newer; this Mac runs $current_macos."
        echo "Skipping Xcode. Update macOS and rerun setup to install the latest release."
        return
    fi

    # Full Xcode is distributed through the App Store, not a Homebrew cask.
    if ! brew list --formula mas >/dev/null 2>&1 && ! command -v mas >/dev/null 2>&1; then
        if ! brew install mas; then
            echo "Skipping Xcode: couldn't install mas; continuing setup." >&2
            return 0
        fi
    fi
    if app_present "Xcode.app" || { xcode-select -p 2>/dev/null | /usr/bin/grep -q '/Xcode[^/]*\.app/Contents/Developer$'; }; then
        echo "Checking for an update to Xcode $latest_version..."
        if ! mas upgrade 497799835; then
            echo "Skipping Xcode update: the App Store upgrade did not complete."
        fi
    else
        echo "Installing Xcode $latest_version (sign in to the Mac App Store if prompted)..."
        if ! mas install 497799835; then
            echo "Skipping Xcode: the App Store installation did not complete."
        fi
    fi
}
install_latest_xcode

# Accept the license for installed Xcode, even if a newer release needs newer macOS.
if app_present "Xcode.app" || { xcode-select -p 2>/dev/null | /usr/bin/grep -q '/Xcode[^/]*\.app/Contents/Developer$'; }; then
    echo "Accepting the Xcode license (administrator password may be required)..."
    if ! sudo xcodebuild -license accept; then
        echo "Skipping Xcode license acceptance; setup will continue."
    fi
fi

# Oh My Zsh is optional; keep later setup steps running if its download fails.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    if ! omz_installer="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" ||
       ! RUNZSH=no CHSH=no sh -c "$omz_installer"; then
        echo "Skipping Oh My Zsh after install failed; continuing setup." >&2
    fi
fi

# Install Nerd Font
echo "Installing Nerd Font..."
install_cask font-meslo-lg-nerd-font "MesloLGS Nerd Font Mono.ttf"

# Copy aliases
mkdir -p ~/.oh-my-zsh/custom
if ensure_file alias_for_bashrc; then
    cp "$SCRIPT_DIR/alias_for_bashrc" ~/.oh-my-zsh/custom/aliases.zsh || echo "Skipping aliases: couldn't copy the file." >&2
else
    echo "Skipping aliases: couldn't download the file." >&2
fi

# Copy git config
if ensure_file .gitconfig; then
    cp "$SCRIPT_DIR/.gitconfig" ~/.gitconfig || echo "Skipping Git config: couldn't copy the file." >&2
else
    echo "Skipping Git config: couldn't download the file." >&2
fi

open_if_installed() {
    local display_name="$1" app_name="$2" cask_name="$3"
    if app_present "$app_name" || brew list --cask "$cask_name" >/dev/null 2>&1; then
        if ! open -a "$display_name"; then
            echo "Couldn't open $display_name; continuing setup." >&2
        fi
    else
        echo "Skipping launch of $display_name because it isn't installed."
    fi
}

echo "Opening iTerm2, Visual Studio Code, and Xcode..."
open_if_installed "iTerm" "iTerm.app" iterm2
open_if_installed "Visual Studio Code" "Visual Studio Code.app" visual-studio-code
if app_present "Xcode.app" || { xcode-select -p 2>/dev/null | /usr/bin/grep -q '/Xcode[^/]*\.app/Contents/Developer$'; }; then
    if ! open -a Xcode; then
        echo "Couldn't open Xcode; continuing setup." >&2
    fi
else
    echo "Skipping launch of Xcode because it isn't installed."
fi

echo "✅ Setup complete! Some items may have been skipped; review messages above."
