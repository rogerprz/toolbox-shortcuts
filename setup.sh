#!/bin/bash

echo "🚀 Setting up new Mac..."

# Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install essentials
echo "Installing dev tools..."
brew install git zsh nvm

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install Nerd Font
echo "Installing Nerd Font..."
brew install --cask font-meslo-lg-nerd-font

# Copy aliases
mkdir -p ~/.oh-my-zsh/custom
cp alias_for_bashrc ~/.oh-my-zsh/custom/aliases.zsh
echo "source \$ZSH/custom/aliases.zsh" >> ~/.zshrc

# Copy git config
cp .gitconfig ~/.gitconfig

# Install recommended tools
brew install fzf bat eza ripgrep tldr gh httpie

echo "✅ Setup complete! Restart your terminal."