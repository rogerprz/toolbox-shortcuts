# Prepare a Mac for coding

This repository helps set up a new MacBook with minimal manual work. The setup is split into two phases so you can review your personal configuration before the rest of the tools and apps are installed.

## 1. Prepare your account and review configuration

Open Terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/rogerprz/toolbox-shortcuts/master/setup.sh | bash
```

The preparation phase installs Homebrew if needed, checks for an existing SSH key, creates an Ed25519 key if none is found, and prepares the Git and Oh My Zsh configuration. It installs VS Code if needed and opens these files there for review:

- `~/.gitconfig`
- `~/.zshrc`
- `~/.oh-my-zsh/custom/aliases.zsh`

Edit and save the files in VS Code before continuing. Existing `.gitconfig`, `.zshrc`, alias files, and default SSH keys are preserved rather than replaced.

If a new SSH key is created, setup uses your global Git email when available; otherwise, it asks for your email. `ssh-keygen` then prompts for an optional passphrase. The public key is copied to your clipboard when possible. Add it to [your GitHub SSH keys](https://github.com/settings/ssh/new) before using SSH with GitHub.

## 2. Install the rest of the tools

After reviewing and saving your configuration, run:

```bash
curl -fsSL https://raw.githubusercontent.com/rogerprz/toolbox-shortcuts/master/setup.sh | bash -s -- --install
```

This phase checks for installed items and installs the missing ones. Homebrew installs the command-line tools and Mac apps. Xcode comes from the Mac App Store; the script checks the latest release and installs or updates it when your macOS version supports it. If Xcode needs a newer macOS, setup skips that step and continues.

The script also sets Chrome as the default browser when Chrome is installed, accepts the Xcode license when Xcode is present, and opens iTerm2, VS Code, and Xcode when available. At the end, it prints what it installed or configured, what it skipped and why, and which apps it opened.

Run both commands in macOS Terminal so setup can prompt for Homebrew administrator access, SSH key details, App Store sign-in, or the Xcode license when needed. The commands download the current `master` version; local edits will be available only after they are committed and pushed to GitHub.

## Included tools and apps

- Command-line tools: Node.js, Python 3, Git, zsh, nvm, fzf, bat, eza, ripgrep, tldr, GitHub CLI, and HTTPie.
- Mac apps: Visual Studio Code, Google Chrome, ChatGPT, Claude, and iTerm2.
- Requested legacy versions: Alfred 3 and Snagit 2022.
- Xcode through the Mac App Store.

## Other repository notes

- [Git commands](./gitCommands.md)
- [Git config template](./gitconfig-template)
- [Shortcuts and aliases](./alias_for_bashrc)
