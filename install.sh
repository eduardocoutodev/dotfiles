#!/bin/bash

# Get the absolute path of the dotfiles directory
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to setup environment
setup_environment() {
    local env_type="$1"
    local zshenv_file="$DOTFILES_DIR/zsh/.zshenv"
    
    # Add or update MACHINE_ENV in .zshenv
    if grep -q "export MACHINE_ENV=" "$zshenv_file"; then
        sed -i '' "s/export MACHINE_ENV=.*/export MACHINE_ENV=\"$env_type\"/" "$zshenv_file"
    else
        echo "export MACHINE_ENV=\"$env_type\"" >> "$zshenv_file"
    fi
}

# Function to create necessary directories
create_directories() {
    mkdir -p "$HOME/.config/zsh/local"
    mkdir -p "$HOME/.config/zsh/conf.d"

    # Create aliases file if it doesn't exist
    touch "$HOME/.config/zsh/local/${ENV_TYPE}/aliases.zsh"
}

# Main installation
echo "Setting up Zsh configuration..."

# Ask for environment type
echo "Select environment type:"
echo "1) mac-m1-personal"
echo "2) mac-m3-work"
read -p "Enter choice (1 or 2): " choice

case $choice in
    1)
        ENV_TYPE="mac-m1-personal"
        ;;
    2)
        ENV_TYPE="mac-m3-work"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Create directories
create_directories

# Setup environment in .zshenv
setup_environment "$ENV_TYPE"

# Use stow to create symlinks
cd "$DOTFILES_DIR"
stow -R zsh

# Create environment-specific config if it doesn't exist
if [ ! -f "$HOME/.config/zsh/local/$ENV_TYPE.zsh" ]; then
    touch "$HOME/.config/zsh/local/$ENV_TYPE.zsh"
    echo "# Environment-specific configuration for $ENV_TYPE" > "$HOME/.config/zsh/local/$ENV_TYPE.zsh"
fi

echo "Installation complete! Environment set to: $ENV_TYPE"