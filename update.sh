#!/bin/bash

CURRENT_DIR=$(pwd)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

echo "${GREEN}Checking for Apple Software updates${RESET}"

softwareupdate -i -a

echo "${GREEN}Ensuring brew is up to date${RESET}"

export HOMEBREW_BUNDLE_FILE="~/dotfiles/.config/homebrew/Brewfile"

brew bundle install

echo "${GREEN}Removing brew packages no longer needed${RESET}"

brew bundle cleanup --force

echo "${GREEN}Ensuring rust toolchain is up to date${RESET}"

# Ensure rustup is available
if ! command -v rustup &> /dev/null; then
    echo "${RED}rustup not found - make sure it's installed via Homebrew${RESET}"
    exit 1
fi

# Install and set stable as default
rustup toolchain install stable
rustup default stable
rustup update

# Verify cargo is available
if command -v cargo &> /dev/null; then
    echo "${GREEN}✅ Rust setup complete - $(rustc --version)${RESET}"
    echo "${GREEN}✅ Cargo available - $(cargo --version)${RESET}"
else
    echo "${RED}❌ Cargo not found after rustup setup${RESET}"
fi

echo "${GREEN}Ensuring repositories are cloned${RESET}"
# Base directory for code repositories
CODE_DIR="$HOME/source/github"

# Function to create directory if it doesn't exist
create_directory() {
  if [ ! -d "$1" ]; then
    echo "${BLUE}Creating directory: $1${RESET}"
    mkdir -p "$1"
  fi
}

# Function to clone repository if it doesn't exist
clone_if_not_exists() {
  local repo_path="$1"
  local repo_url="$2"

  if [ ! -d "$repo_path" ]; then
    echo "${BLUE}Cloning repository: $repo_url${RESET}"
    gh repo clone "$repo_url" "$repo_path"
  else
    echo "${GREEN}Repository already exists: $repo_path${RESET}"
  fi
}

# Create base directory
create_directory "$CODE_DIR"

# Change to code directory
cd "$CODE_DIR" || {
  echo "Error: Could not change to directory $CODE_DIR"
  exit 1
}

# List of repositories to clone
repositories=(
  "hedge-ops/app"
  "hedge-ops/product-website"
  "hedge-ops/company-website"
  "hedge-ops/website"
  "hedge-ops/prototyping"
)

# Create necessary parent directories and clone repositories
for repo_url in "${repositories[@]}"; do
  repo_path="$CODE_DIR/$repo_url"
  parent_dir=$(dirname "$repo_path")

  # Create parent directory
  create_directory "$parent_dir"

  # Clone repository if it doesn't exist
  clone_if_not_exists "$repo_path" "$repo_url"
done

echo "${GREEN}Linking ~./people to app data directory${RESET}"
if [ ! -d "$HOME/Library/Application Support/io.people-work" ]; then
  mkdir -p "$HOME/Library/Application Support/io.people-work"
  echo "${BLUE}Created io.people-work directory${RESET}"
fi

# Create the symlink if it doesn't exist
if [ ! -L "$HOME/people" ]; then
  ln -s "$HOME/Library/Application Support/io.people-work" "$HOME/people"
  echo "${BLUE}Created symlink to ~/people${RESET}"
fi

# Create .config directory if it doesn't exist
mkdir -p ~/.config

# Define files and directories to link
files_to_link=(
  ".zshrc"
  "update.sh"
)

config_dirs_to_link=(
  "ghostty"
  "git"
  "homebrew"
  "starship"
)

# Link individual files
for file in "${files_to_link[@]}"; do
  if [ ! -L ~/"$file" ]; then
    ln -s ~/dotfiles/"$file" ~/"$file"
    echo "${BLUE}Created symlink for $file${RESET}"
  fi
done

# Link .config directories
for dir in "${config_dirs_to_link[@]}"; do
  if [ ! -L ~/.config/"$dir" ]; then
    ln -s ~/dotfiles/.config/"$dir" ~/.config/"$dir"
    echo "${BLUE}Created symlink for .config/$dir${RESET}"
  fi
done

cd "$CURRENT_DIR"

echo "${GREEN}Done!${RESET}"