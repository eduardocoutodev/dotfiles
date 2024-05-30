# My Dotfiles

Welcome to my dotfiles repository! This README will guide you through the setup process, ensuring you have all the necessary tools installed and configured.

## Requirements

### 1. Install Git

Make sure you have Git installed on your machine. If not, you can install it via Homebrew:

```sh
brew install git
```

### 2. Install JetBrains Mono Nerd Font

### 3. Install fzf

fzf is a command-line fuzzy finder. Install it using Homebrew:

```sh
brew install fzf
```

### 4. Install zoxide

zoxide is a smarter cd command for your terminal. Install it using Homebrew:

```sh
brew install zoxide
```

### 5. Install GNU Stow

GNU Stow is a symlink farm manager, perfect for managing your dotfiles. Install it using Homebrew:

```sh
brew install stow
```

### 6. Install BatCat

```sh
brew install bat
```

## Setup

After installing the necessary tools, run the following command to set up your dotfiles:

```sh
cd ~/Dotfiles
stow .
```
