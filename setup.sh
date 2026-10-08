#!/bin/bash

set -euo pipefail
SETUP_MODE="--configure"
SETUP_GIT_NAME="${SETUP_GIT_NAME:-}"
SETUP_GIT_EMAIL="${SETUP_GIT_EMAIL:-}"
SETUP_GIT_USERNAME="${SETUP_GIT_USERNAME:-}"
while [ "$#" -gt 0 ]; do
    case "$1" in
        --configure|--install)
            SETUP_MODE="$1"
            shift
            ;;
        --name)
            if [ "$#" -lt 2 ]; then echo "Missing value for --name" >&2; exit 2; fi
            SETUP_GIT_NAME="$2"
            shift 2
            ;;
        --email)
            if [ "$#" -lt 2 ]; then echo "Missing value for --email" >&2; exit 2; fi
            SETUP_GIT_EMAIL="$2"
            shift 2
            ;;
        --username)
            if [ "$#" -lt 2 ]; then echo "Missing value for --username" >&2; exit 2; fi
            SETUP_GIT_USERNAME="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: setup.sh [--configure|--install] [--name 'Your Name'] [--email you@example.com] [--username your-github-name]"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; echo "Usage: setup.sh [--configure|--install] [--name 'Your Name'] [--email you@example.com] [--username your-github-name]" >&2; exit 2 ;;
    esac
done
RAW_BASE="https://raw.githubusercontent.com/rogerprz/toolbox-shortcuts/master"
SETUP_TEMP_DIR=""
SUMMARY_INSTALLED=()
SUMMARY_SKIPPED=()
SUMMARY_OPENED=()
SETUP_FILES=()
SETUP_CODE_LAUNCHER=""
trap 'if [ -n "$SETUP_TEMP_DIR" ]; then rm -rf "$SETUP_TEMP_DIR"; fi' EXIT
if [ -n "${BASH_SOURCE[0]:-}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    # A piped script has no source directory; fetch companion files on demand.
    SETUP_TEMP_DIR="$(mktemp -d)"
    SCRIPT_DIR="$SETUP_TEMP_DIR"
fi

record_installed() { SUMMARY_INSTALLED+=("$1"); }
record_skipped() { SUMMARY_SKIPPED+=("$1"); }
record_opened() { SUMMARY_OPENED+=("$1"); }

countdown_before_open() {
    echo "Opening the configuration files in:"
    local seconds
    for seconds in 5 4 3 2 1; do
        printf '  %s...\n' "$seconds"
        sleep 1
    done
}

print_summary() {
    echo
    printf '%s\n' "========================================" "Setup summary" "========================================"
    if [ "${#SUMMARY_INSTALLED[@]}" -gt 0 ]; then
        printf 'Installed / configured:\n'
        for item in "${SUMMARY_INSTALLED[@]}"; do printf '  ✓ %s\n' "$item"; done
    else
        printf '%s\n' 'Installed / configured: none'
    fi
    if [ "${#SUMMARY_SKIPPED[@]}" -gt 0 ]; then
        printf 'Skipped:\n'
        for item in "${SUMMARY_SKIPPED[@]}"; do printf '  - %s\n' "$item"; done
    else
        printf '%s\n' 'Skipped: none'
    fi
    if [ "${1:-}" != "before-open" ]; then
        if [ "${#SUMMARY_OPENED[@]}" -gt 0 ]; then
            printf 'Opened:\n'
            for item in "${SUMMARY_OPENED[@]}"; do printf '  ↗ %s\n' "$item"; done
        else
            printf '%s\n' 'Opened: none'
        fi
    fi
    printf '%s\n' '========================================'
}

ensure_file() {
    local relative_path="$1"
    if [ ! -f "$SCRIPT_DIR/$relative_path" ]; then
        mkdir -p "$(dirname "$SCRIPT_DIR/$relative_path")"
        curl -fsSL "$RAW_BASE/$relative_path" -o "$SCRIPT_DIR/$relative_path"
    fi
}

echo "🚀 Setting up new Mac..."

# Find Homebrew even when a fresh installation is not on PATH yet.
HOMEBREW_WAS_PRESENT=0
if command -v brew >/dev/null 2>&1; then HOMEBREW_WAS_PRESENT=1; fi
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
if [ "$HOMEBREW_WAS_PRESENT" -eq 1 ]; then
    record_skipped "Homebrew (already installed)"
else
    record_installed "Homebrew"
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
        record_skipped "$formula (already installed)"
    elif brew install "$formula"; then
        record_installed "$formula"
    else
        echo "Skipping $formula after Homebrew install failed; continuing setup." >&2
        record_skipped "$formula (install failed)"
    fi
}

install_cask() {
    local cask="$1"
    shift
    if app_present "$@" || brew list --cask "$cask" >/dev/null 2>&1; then
        echo "Skipping $cask (already installed)."
        record_skipped "$cask (already installed)"
    elif brew install --cask "$cask"; then
        record_installed "$cask"
    else
        echo "Skipping $cask after Homebrew install failed; continuing setup." >&2
        record_skipped "$cask (install failed)"
    fi
}

# Use a local tap for the requested Snagit 2022 version.
install_legacy_cask() {
    local cask="$1" tap_dir
    shift
    if app_present "$@" || brew list --cask "$cask" >/dev/null 2>&1; then
        echo "Skipping $cask (already installed)."
        record_skipped "$cask (already installed)"
        return
    fi
    if ! brew tap | /usr/bin/grep -qx "toolbox-shortcuts/legacy"; then
        if ! brew tap-new toolbox-shortcuts/legacy; then
            echo "Skipping $cask: couldn't create the Homebrew tap; continuing setup." >&2
            record_skipped "$cask (Homebrew tap failed)"
            return 0
        fi
    fi
    if ! tap_dir="$(brew --repository toolbox-shortcuts/legacy)"; then
        echo "Skipping $cask: couldn't locate the Homebrew tap; continuing setup." >&2
        record_skipped "$cask (Homebrew tap unavailable)"
        return 0
    fi
    if ! mkdir -p "$tap_dir/Casks"; then
        echo "Skipping $cask: couldn't prepare the Homebrew tap; continuing setup." >&2
        record_skipped "$cask (tap directory unavailable)"
        return 0
    fi
    if ! ensure_file "Casks/$cask.rb" || ! cp "$SCRIPT_DIR/Casks/$cask.rb" "$tap_dir/Casks/$cask.rb"; then
        echo "Skipping $cask: couldn't prepare its Homebrew cask; continuing setup." >&2
        record_skipped "$cask (cask setup failed)"
        return 0
    fi
    if brew install --cask "toolbox-shortcuts/legacy/$cask"; then
        record_installed "$cask"
    else
        echo "Skipping $cask after Homebrew install failed; continuing setup." >&2
        record_skipped "$cask (install failed)"
    fi
}

setup_git_config() {
    local gitconfig_temp=""
    if [ -f "$HOME/.gitconfig" ]; then
        if update_todo_git_identity "$HOME/.gitconfig"; then
            if [ "$GIT_IDENTITY_UPDATED" -eq 1 ]; then
                record_installed "Git identity in existing ~/.gitconfig"
            else
                echo "Keeping existing ~/.gitconfig for you to review/edit."
                record_skipped "Git config (existing file preserved)"
            fi
            report_git_identity_placeholders "$HOME/.gitconfig"
        else
            echo "Keeping existing ~/.gitconfig for you to review/edit."
            record_skipped "Git config (existing file preserved)"
        fi
    elif ensure_file .gitconfig && gitconfig_temp="$(mktemp "$HOME/.gitconfig.toolbox-new.XXXXXX")" &&
         cp "$SCRIPT_DIR/.gitconfig" "$gitconfig_temp" &&
         update_todo_git_identity "$gitconfig_temp" &&
         mv "$gitconfig_temp" "$HOME/.gitconfig"; then
        record_installed "Git config (~/.gitconfig)"
        report_git_identity_placeholders "$HOME/.gitconfig"
    else
        [ -z "$gitconfig_temp" ] || rm -f "$gitconfig_temp"
        echo "Skipping Git config: couldn't install the file." >&2
        record_skipped "Git config (file unavailable)"
    fi
}

report_git_identity_placeholders() {
    local gitconfig_file="$1" current_name current_email
    current_name="$(git config --file "$gitconfig_file" --get user.name 2>/dev/null || true)"
    current_email="$(git config --file "$gitconfig_file" --get user.email 2>/dev/null || true)"
    local current_username
    current_username="$(git config --file "$gitconfig_file" --get user.username 2>/dev/null || true)"
    if [ "$current_name" = "TODO Name" ] || [ "$current_email" = "todo@email.com" ] || [ "$current_username" = "TODO GitHub username" ]; then
        echo "Git identity placeholders remain in ~/.gitconfig; search for 'todo' and replace the values, or rerun with identity options."
        record_skipped "Git identity placeholders (~/.gitconfig)"
    fi
}

update_todo_git_identity() {
    local gitconfig_file="$1" current_name current_email current_username
    GIT_IDENTITY_UPDATED=0
    current_name="$(git config --file "$gitconfig_file" --get user.name 2>/dev/null || true)"
    current_email="$(git config --file "$gitconfig_file" --get user.email 2>/dev/null || true)"
    current_username="$(git config --file "$gitconfig_file" --get user.username 2>/dev/null || true)"
    if [ -n "$SETUP_GIT_NAME" ] && { [ -z "$current_name" ] || [ "$current_name" = "TODO Name" ]; }; then
        git config --file "$gitconfig_file" user.name "$SETUP_GIT_NAME" || return 1
        GIT_IDENTITY_UPDATED=1
    fi
    if [ -n "$SETUP_GIT_EMAIL" ] && { [ -z "$current_email" ] || [ "$current_email" = "todo@email.com" ]; }; then
        git config --file "$gitconfig_file" user.email "$SETUP_GIT_EMAIL" || return 1
        GIT_IDENTITY_UPDATED=1
    fi
    if [ -n "$SETUP_GIT_USERNAME" ] && { [ -z "$current_username" ] || [ "$current_username" = "TODO GitHub username" ]; }; then
        git config --file "$gitconfig_file" user.username "$SETUP_GIT_USERNAME" || return 1
        GIT_IDENTITY_UPDATED=1
    fi
    return 0
}

setup_shell_config() {
    if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
        echo "Installing or repairing Oh My Zsh..."
        install_formula git brew-only
        local omz_custom_dir="$HOME/.oh-my-zsh/custom"
        local omz_target="$HOME/.oh-my-zsh"
        local omz_stage=""
        local omz_backup=""
        local omz_ready=0

        if omz_stage="$(mktemp -d)" && git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$omz_stage/framework" >/dev/null 2>&1 &&
           [ -f "$omz_stage/framework/oh-my-zsh.sh" ]; then
            if [ -e "$omz_target" ]; then
                omz_backup="${omz_target}.toolbox-backup.$(date +%Y%m%d%H%M%S)"
                if ! mv "$omz_target" "$omz_backup"; then
                    echo "Skipping Oh My Zsh repair: couldn't preserve the incomplete directory." >&2
                    record_skipped "Oh My Zsh (existing directory could not be moved)"
                fi
            fi
            if [ ! -e "$omz_target" ] && mv "$omz_stage/framework" "$omz_target"; then
                omz_ready=1
                if [ -n "$omz_backup" ] && [ -d "$omz_backup/custom" ]; then
                    mkdir -p "$omz_custom_dir"
                    if cp -R "$omz_backup/custom/." "$omz_custom_dir/"; then
                        echo "Preserved custom Oh My Zsh files from $omz_backup/custom."
                    else
                        echo "Warning: couldn't restore all custom Oh My Zsh files; backup remains at $omz_backup." >&2
                    fi
                fi
                if [ -n "$omz_backup" ]; then
                    echo "Preserved the previous incomplete Oh My Zsh directory at $omz_backup."
                fi
                record_installed "Oh My Zsh framework"
            fi
        else
            echo "Skipping Oh My Zsh install after download/clone failure; setup will continue." >&2
            record_skipped "Oh My Zsh (download or clone failed)"
        fi
        [ -z "$omz_stage" ] || rm -rf "$omz_stage"
        if [ "$omz_ready" -eq 0 ] && [ -n "$omz_backup" ] && [ -e "$omz_backup" ] && [ ! -e "$omz_target" ]; then
            mv "$omz_backup" "$omz_target"
        fi
    else
        record_skipped "Oh My Zsh (already installed)"
    fi

    if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
        echo "Skipping Oh My Zsh activation and aliases because the framework is incomplete." >&2
        record_skipped "Oh My Zsh activation and aliases (framework unavailable)"
        return 0
    fi

    # Install the two Oh My Zsh plugins that are not included in its framework.
    install_omz_plugin() {
        local plugin="$1" repository="$2" entry_file="$1.plugin.zsh"
        local plugin_root="$HOME/.oh-my-zsh/custom/plugins"
        local plugin_dir="$plugin_root/$plugin"
        local plugin_stage=""
        if [ "$plugin" = "zsh-syntax-highlighting" ]; then
            entry_file="zsh-syntax-highlighting.plugin.zsh"
        fi
        if [ -d "$plugin_dir" ]; then
            record_skipped "Oh My Zsh plugin $plugin (already installed)"
        elif ! mkdir -p "$plugin_root"; then
            echo "Skipping Oh My Zsh plugin $plugin: couldn't create the plugin directory." >&2
            record_skipped "Oh My Zsh plugin $plugin (directory unavailable)"
        elif plugin_stage="$(mktemp -d)" && git clone --depth 1 "$repository" "$plugin_stage/$plugin" >/dev/null 2>&1 &&
             [ -f "$plugin_stage/$plugin/$entry_file" ]; then
            if mv "$plugin_stage/$plugin" "$plugin_dir"; then
                record_installed "Oh My Zsh plugin $plugin"
            else
                echo "Skipping Oh My Zsh plugin $plugin: couldn't install it." >&2
                record_skipped "Oh My Zsh plugin $plugin (install failed)"
            fi
        else
            echo "Skipping Oh My Zsh plugin $plugin: repository clone failed." >&2
            record_skipped "Oh My Zsh plugin $plugin (clone failed)"
        fi
        [ -z "$plugin_stage" ] || rm -rf "$plugin_stage"
    }

    install_omz_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
    install_omz_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git

    if ! mkdir -p "$HOME/.oh-my-zsh/custom"; then
        echo "Skipping aliases: couldn't create the custom directory." >&2
        record_skipped "shell aliases (directory unavailable)"
    elif [ -f "$HOME/.oh-my-zsh/custom/aliases.zsh" ]; then
        record_skipped "shell aliases (existing file preserved)"
    elif ensure_file alias_for_bashrc && cp "$SCRIPT_DIR/alias_for_bashrc" "$HOME/.oh-my-zsh/custom/aliases.zsh"; then
        record_installed "shell aliases"
    elif touch "$HOME/.oh-my-zsh/custom/aliases.zsh"; then
        echo "Created an empty aliases.zsh so it is ready to edit in VS Code." >&2
        record_skipped "shell aliases template (unavailable; empty file created)"
    else
        echo "Skipping aliases: couldn't create the target file." >&2
        record_skipped "shell aliases (file unavailable)"
    fi

    # Install the reviewed template after the framework, plugins, and aliases
    # are ready. Back up any existing personal .zshrc before replacing it.
    if /usr/bin/grep -Fq '# Managed by toolbox-shortcuts.' "$HOME/.zshrc"; then
        record_skipped "Shell config (~/.zshrc already uses toolbox-shortcuts template)"
    elif ensure_file .zshrc.template; then
        local zshrc_backup="" zshrc_temp=""
        if [ -f "$HOME/.zshrc" ]; then
            if zshrc_backup="$(mktemp "$HOME/.zshrc.toolbox-backup.XXXXXX")" && cp -p "$HOME/.zshrc" "$zshrc_backup"; then
                echo "Backed up the existing ~/.zshrc to $zshrc_backup."
            else
                [ -z "$zshrc_backup" ] || rm -f "$zshrc_backup"
                echo "Skipping .zshrc template: couldn't back up the existing file." >&2
                record_skipped "Shell config template (backup failed)"
                return 0
            fi
        fi

        if zshrc_temp="$(mktemp "$HOME/.zshrc.toolbox-new.XXXXXX")" &&
           cp "$SCRIPT_DIR/.zshrc.template" "$zshrc_temp" &&
           mv "$zshrc_temp" "$HOME/.zshrc"; then
            record_installed "Shell config template (~/.zshrc)"
        else
            [ -z "$zshrc_temp" ] || rm -f "$zshrc_temp"
            echo "Skipping .zshrc template: couldn't install it." >&2
            record_skipped "Shell config template (install failed)"
        fi
    else
        echo "Skipping .zshrc template: template unavailable." >&2
        record_skipped "Shell config template (unavailable)"
    fi
}

setup_ssh_key() {
    local key_name key_path ssh_email
    mkdir -p "$HOME/.ssh" || {
        echo "Skipping SSH key setup: couldn't create ~/.ssh." >&2
        record_skipped "SSH key (couldn't create ~/.ssh)"
        return 0
    }
    chmod 700 "$HOME/.ssh" 2>/dev/null || true
    for key_name in id_ed25519 id_rsa id_ecdsa; do
        key_path="$HOME/.ssh/$key_name"
        if [ -f "$key_path" ] || [ -f "$key_path.pub" ]; then
            echo "Skipping SSH key generation; found $key_path or its public key."
            record_skipped "SSH key (existing $key_name key)"
            return 0
        fi
    done

    if [ ! -r /dev/tty ]; then
        echo "Skipping SSH key setup: run this from Terminal to answer the key prompts." >&2
        record_skipped "SSH key (interactive terminal unavailable)"
        return 0
    fi
    ssh_email="$(git config --global user.email 2>/dev/null || true)"
    if [ -z "$ssh_email" ] || [ "$ssh_email" = "todo@email.com" ]; then
        ssh_email="$SETUP_GIT_EMAIL"
    fi
    if [ -z "$ssh_email" ]; then
        read -r -p "Email address for your new SSH key: " ssh_email </dev/tty || ssh_email=""
    fi
    if [ -z "$ssh_email" ]; then
        echo "Skipping SSH key setup: no email address was provided." >&2
        record_skipped "SSH key (email not provided)"
        return 0
    fi
    local current_git_email
    current_git_email="$(git config --global user.email 2>/dev/null || true)"
    if [ "$current_git_email" = "todo@email.com" ] && [ -n "$ssh_email" ]; then
        git config --global user.email "$ssh_email" && record_installed "Git email from SSH key prompt" || true
    fi

    echo "Creating an Ed25519 SSH key. You can enter a passphrase or press Return for none."
    if ssh-keygen -t ed25519 -C "$ssh_email" -f "$HOME/.ssh/id_ed25519" </dev/tty; then
        record_installed "SSH key (~/.ssh/id_ed25519)"
        if command -v pbcopy >/dev/null 2>&1 && pbcopy < "$HOME/.ssh/id_ed25519.pub"; then
            echo "Public key copied to the clipboard. Add it to your GitHub SSH keys."
            record_installed "SSH public key copied to clipboard"
        else
            echo "Add this public key to your GitHub SSH keys:"
            cat "$HOME/.ssh/id_ed25519.pub"
            record_skipped "SSH public key clipboard copy (pbcopy unavailable)"
        fi
    else
        echo "Skipping SSH key setup after ssh-keygen failed; continuing setup." >&2
        record_skipped "SSH key (generation failed)"
    fi
}

install_code_command() {
    local code_dir="" candidate profile="$HOME/.zprofile"
    if ! touch "$profile"; then
        echo "Skipping VS Code CLI setup: couldn't create ~/.zprofile." >&2
        record_skipped "VS Code code command (.zprofile unavailable)"
        return 0
    fi
    if command -v code >/dev/null 2>&1; then
        record_skipped "VS Code code command (already in PATH)"
        return 0
    fi
    for candidate in "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" \
                     "$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin"; do
        if [ -x "$candidate/code" ]; then
            code_dir="$candidate"
            break
        fi
    done
    if [ -z "$code_dir" ]; then
        echo "Skipping VS Code CLI setup: couldn't find the code launcher in the app." >&2
        record_skipped "VS Code code command (launcher unavailable)"
        return 0
    fi
    if ! touch "$profile"; then
        echo "Skipping VS Code CLI setup: couldn't update ~/.zprofile." >&2
        record_skipped "VS Code code command (.zprofile unavailable)"
        return 0
    fi
    if ! /usr/bin/grep -Fq "$code_dir" "$profile"; then
        if ! /usr/bin/printf '\n# Visual Studio Code command line\nexport PATH="$PATH:%s"\n' "$code_dir" >> "$profile"; then
            echo "Skipping VS Code CLI setup: couldn't update ~/.zprofile." >&2
            record_skipped "VS Code code command (.zprofile update failed)"
            return 0
        fi
    fi
    PATH="$code_dir:$PATH"
    export PATH
    if command -v code >/dev/null 2>&1; then
        echo "Added the VS Code Shell Command ('code') to PATH; new terminals will load ~/.zprofile."
        record_installed "VS Code code command (PATH)"
    else
        echo "Skipping VS Code CLI setup: the code launcher isn't executable." >&2
        record_skipped "VS Code code command (launcher failed)"
    fi
}

prepare_setup_files() {
    local setup_file candidate
    SETUP_CODE_LAUNCHER="$(command -v code 2>/dev/null || true)"
    SETUP_FILES=()
    if [ -z "$SETUP_CODE_LAUNCHER" ]; then
        for candidate in \
            "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" \
            "$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"; do
            if [ -x "$candidate" ]; then
                SETUP_CODE_LAUNCHER="$candidate"
                break
            fi
        done
    fi

    for setup_file in "$HOME/.gitconfig" "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.oh-my-zsh/custom/aliases.zsh"; do
        if [ -f "$setup_file" ]; then
            SETUP_FILES+=("$setup_file")
        else
            echo "Skipping missing config file: $setup_file" >&2
            record_skipped "Config file ($setup_file missing)"
        fi
    done

    if [ -z "$SETUP_CODE_LAUNCHER" ] || [ ! -x "$SETUP_CODE_LAUNCHER" ] || [ "${#SETUP_FILES[@]}" -eq 0 ]; then
        echo "Skipping config editor: VS Code's code launcher or config files aren't available." >&2
        record_skipped "Setup files in Visual Studio Code (launcher or files unavailable)"
    fi
}

announce_setup_files() {
    if [ -n "$SETUP_CODE_LAUNCHER" ] && [ -x "$SETUP_CODE_LAUNCHER" ] && [ "${#SETUP_FILES[@]}" -gt 0 ]; then
        echo
        printf '%s\n' "========================================" "Opening ${#SETUP_FILES[@]} files in Visual Studio Code" "========================================"
        printf '  • %s\n' "${SETUP_FILES[@]}"
        echo "Please confirm your name, email, and username by searching for 'todo' in the opened files."
    fi
}

open_setup_files() {
    if [ -n "$SETUP_CODE_LAUNCHER" ] && [ -x "$SETUP_CODE_LAUNCHER" ] && [ "${#SETUP_FILES[@]}" -gt 0 ]; then
        if "$SETUP_CODE_LAUNCHER" --new-window "${SETUP_FILES[@]}"; then
            record_opened "Configuration files in Visual Studio Code"
            echo "Opened all configuration files in Visual Studio Code."
        else
            echo "Couldn't open the configuration files with VS Code's code launcher; continuing." >&2
            record_skipped "Setup files in Visual Studio Code (code launcher failed)"
        fi
    fi
}

# Prepare identity first, then make editable settings available before the app installs.
setup_git_config
setup_ssh_key
setup_shell_config
install_cask visual-studio-code "Visual Studio Code.app"
install_code_command
if [ "$SETUP_MODE" = "--configure" ]; then
    prepare_setup_files
    echo "Configuration is ready. Review the files after VS Code opens, then run the install phase:"
    echo "curl -fsSL https://raw.githubusercontent.com/rogerprz/toolbox-shortcuts/master/setup.sh | bash -s -- --install"
    print_summary before-open
    announce_setup_files
    if [ -n "$SETUP_CODE_LAUNCHER" ] && [ -x "$SETUP_CODE_LAUNCHER" ] && [ "${#SETUP_FILES[@]}" -gt 0 ]; then
        countdown_before_open
        open_setup_files
    fi
    exit 0
fi

install_formula node
install_formula python brew-only
# Install Homebrew tools before Xcode, whose download or license step can be skipped.
install_formula zsh
install_formula nvm
install_formula fzf
install_formula bat
install_formula eza
install_formula ripgrep
install_formula tldr
install_formula gh
install_formula httpie
install_formula supabase/tap/supabase supabase
install_formula getsentry/tools/sentry sentry
install_cask google-chrome "Google Chrome.app"
if app_present "Google Chrome.app" || brew list --cask google-chrome >/dev/null 2>&1; then
    install_formula defaultbrowser
    if command -v defaultbrowser >/dev/null 2>&1; then
        if ! defaultbrowser chrome; then
            echo "Skipping Chrome default-browser setting; macOS did not accept the change." >&2
            record_skipped "Chrome default browser (setting failed)"
        else
            record_installed "Chrome default browser"
        fi
    else
        echo "Skipping Chrome default-browser setting: defaultbrowser is unavailable." >&2
        record_skipped "Chrome default browser (utility unavailable)"
    fi
else
    echo "Skipping Chrome default-browser setting because Chrome isn't installed." >&2
    record_skipped "Chrome default browser (Chrome unavailable)"
fi
install_cask chatgpt "ChatGPT.app"
install_cask claude "Claude.app"
install_cask iterm2 "iTerm.app" "iTerm2.app"
install_cask alfred "Alfred 5.app"
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
        record_skipped "Xcode (version check failed)"
        return 0
    fi
    if ! latest_version="$(/usr/bin/plutil -extract results.0.version raw -o - "$metadata")" ||
       ! minimum_macos="$(/usr/bin/plutil -extract results.0.minimumOsVersion raw -o - "$metadata")"; then
        echo "Skipping Xcode: couldn't read the latest App Store version."
        record_skipped "Xcode (version lookup failed)"
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
        record_skipped "Xcode latest (requires macOS $minimum_macos)"
        return 0
    fi

    # Full Xcode is distributed through the App Store, not a Homebrew cask.
    if brew list --formula mas >/dev/null 2>&1 || command -v mas >/dev/null 2>&1; then
        record_skipped "mas (already installed)"
    elif brew install mas; then
        record_installed "mas"
    else
        echo "Skipping Xcode: couldn't install mas; continuing setup." >&2
        record_skipped "Xcode (mas install failed)"
        return 0
    fi
    if app_present "Xcode.app" || { xcode-select -p 2>/dev/null | /usr/bin/grep -q '/Xcode[^/]*\.app/Contents/Developer$'; }; then
        echo "Checking for an update to Xcode $latest_version..."
        if mas upgrade 497799835; then
            record_installed "Xcode (latest checked/updated)"
        else
            echo "Skipping Xcode update: the App Store upgrade did not complete."
            record_skipped "Xcode update (App Store failed)"
        fi
    else
        echo "Installing Xcode $latest_version (sign in to the Mac App Store if prompted)..."
        if mas install 497799835; then
            record_installed "Xcode"
        else
            echo "Skipping Xcode: the App Store installation did not complete."
            record_skipped "Xcode (App Store install failed)"
        fi
    fi
}
install_latest_xcode

# Accept the license for installed Xcode, even if a newer release needs newer macOS.
if app_present "Xcode.app" || { xcode-select -p 2>/dev/null | /usr/bin/grep -q '/Xcode[^/]*\.app/Contents/Developer$'; }; then
    echo "Accepting the Xcode license (administrator password may be required)..."
    if sudo xcodebuild -license accept; then
        record_installed "Xcode license accepted"
    else
        echo "Skipping Xcode license acceptance; setup will continue."
        record_skipped "Xcode license (acceptance failed)"
    fi
fi

# Install Nerd Font
echo "Installing Nerd Font..."
install_cask font-meslo-lg-nerd-font "MesloLGS Nerd Font Mono.ttf"

open_if_installed() {
    local display_name="$1" app_name="$2" cask_name="$3"
    if app_present "$app_name" || brew list --cask "$cask_name" >/dev/null 2>&1; then
        if open -a "$display_name"; then
            record_opened "$display_name"
        else
            echo "Couldn't open $display_name; continuing setup." >&2
            record_skipped "$display_name (launch failed)"
        fi
    else
        echo "Skipping launch of $display_name because it isn't installed."
        record_skipped "$display_name (not installed)"
    fi
}

echo "Opening iTerm2, Visual Studio Code, and Xcode..."
open_if_installed "iTerm" "iTerm.app" iterm2
open_if_installed "Visual Studio Code" "Visual Studio Code.app" visual-studio-code
if app_present "Xcode.app" || { xcode-select -p 2>/dev/null | /usr/bin/grep -q '/Xcode[^/]*\.app/Contents/Developer$'; }; then
    if open -a Xcode; then
        record_opened "Xcode"
    else
        echo "Couldn't open Xcode; continuing setup." >&2
        record_skipped "Xcode (launch failed)"
    fi
else
    echo "Skipping launch of Xcode because it isn't installed."
    record_skipped "Xcode (not installed; not opened)"
fi

print_summary
