# Setup for a new MacBook

This repository's main purpose is to make a new MacBook ready for coding with as little manual setup as possible. Run the setup command from Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/rogerprz/toolbox-shortcuts/master/setup.sh | bash
```

The command downloads and runs the current `master` version of `setup.sh`. Changes in your local checkout will not be included until they are committed and pushed to GitHub.

## What setup does

The script checks for existing tools and apps, installs missing ones, and prints an installed, skipped, and opened summary at the end. Homebrew is used for the command-line tools and Mac apps. Xcode is installed from the Mac App Store because Apple distributes it there; the script checks the latest release and installs or updates it when the current macOS version supports it.

It sets Chrome as the default browser, accepts the Xcode license when Xcode is installed, configures the repository's Git settings, and opens iTerm2, Visual Studio Code, and Xcode when available.

## SSH key setup

If no default SSH key is found in `~/.ssh` (`id_ed25519`, `id_rsa`, or `id_ecdsa`), setup creates an Ed25519 key. It uses the email in your global Git config when available; otherwise, it asks for one. `ssh-keygen` then asks whether you want to protect the private key with a passphrase. The public key is copied to your clipboard when `pbcopy` is available.

Add the public key to your GitHub account at [github.com/settings/ssh/new](https://github.com/settings/ssh/new) before using SSH to access GitHub repositories. If the key was copied, paste it into GitHub's key field. To verify access afterward, run:

```bash
ssh -T git@github.com
```

The script never replaces a detected default key.

## Prompts and prerequisites

Run the command in macOS Terminal so setup can use the terminal for Homebrew and SSH prompts. Depending on what needs installing, setup may ask for your Mac administrator password, App Store sign-in, and an SSH key passphrase. Xcode's latest version may require a newer macOS; in that case, setup skips the Xcode update and explains the requirement while continuing with the other items.

## Included tools and apps

The setup script installs these when they are missing:

- Command-line tools: Node.js, Python 3, Git, zsh, nvm, fzf, bat, eza, ripgrep, tldr, GitHub CLI, and HTTPie.
- Mac apps: Visual Studio Code, Google Chrome, ChatGPT, Claude, and iTerm2.
- Requested legacy versions: Alfred 3 and Snagit 2022.
- Xcode through the Mac App Store.

## Run setup again

The script checks for installed items, so you can rerun the same command after an interrupted setup. Review its final summary for anything it skipped, then rerun or complete any account-specific step such as adding your SSH public key to GitHub.

## Other repository notes

- [Git commands](./gitCommands.md)
- [Git config template](./gitconfig-template)
- [Shortcuts and aliases](./alias_for_bashrc)
