#!/bin/bash

CURRENT_DIR=$(pwd)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

echo "${GREEN}Checking for Apple Software updates${RESET}"

softwareupdate -i -a

echo "${GREEN}Ensuring brew is up to date${RESET}"

export HOMEBREW_BUNDLE_FILE="$HOME/dotfiles/.config/homebrew/Brewfile"

brew bundle install

echo "${GREEN}Removing brew packages no longer needed${RESET}"

brew bundle cleanup --force

echo "${GREEN}Ensuring rust toolchain is up to date${RESET}"

# Ensure rustup is available
if ! command -v rustup &> /dev/null; then
    echo "${RED}rustup not found - make sure it's installed via Homebrew${RESET}"
    exit 1
fi

# Clean up any conflicting Homebrew symlinks in ~/.cargo/bin
if [ -L ~/.cargo/bin/rustup ]; then
    rm ~/.cargo/bin/rustup
    echo "${BLUE}Removed conflicting rustup symlink${RESET}"
fi

# Install and set stable as default
rustup toolchain install stable
rustup default stable
rustup update

# Ensure essential components are installed
rustup component add rustfmt clippy rust-src

# Get the active toolchain path for manual symlink creation if needed
TOOLCHAIN_PATH=$(rustup which cargo | sed 's|/bin/cargo||')

# Ensure ~/.cargo/bin directory exists
mkdir -p ~/.cargo/bin

# Ensure cargo-fmt and cargo-clippy symlinks exist for cargo subcommands
for cmd in cargo-fmt cargo-clippy; do
    if [ ! -f ~/.cargo/bin/$cmd ] && [ -f "$TOOLCHAIN_PATH/bin/$cmd" ]; then
        ln -sf "$TOOLCHAIN_PATH/bin/$cmd" ~/.cargo/bin/$cmd
        echo "${BLUE}Created $cmd symlink${RESET}"
    fi
done

# Verify all tools are available
if command -v cargo &> /dev/null && command -v rustfmt &> /dev/null; then
    echo "${GREEN}✅ Rust setup complete - $(rustc --version)${RESET}"
    echo "${GREEN}✅ Cargo available - $(cargo --version)${RESET}"
    echo "${GREEN}✅ Rustfmt available - $(rustfmt --version)${RESET}"
    
    # Test cargo fmt and clippy specifically
    if cargo fmt --version &> /dev/null && cargo clippy --version &> /dev/null; then
        echo "${GREEN}✅ Cargo fmt and clippy available${RESET}"
    else
        echo "${BLUE}Some cargo subcommands not working, attempting manual fix...${RESET}"
        
        # Create all necessary cargo subcommand symlinks
        for cmd in cargo-fmt cargo-clippy; do
            if [ -f "$TOOLCHAIN_PATH/bin/$cmd" ] && [ ! -f ~/.cargo/bin/$cmd ]; then
                ln -sf "$TOOLCHAIN_PATH/bin/$cmd" ~/.cargo/bin/$cmd
                echo "${BLUE}Created $cmd symlink${RESET}"
            fi
        done
        
        # Test again
        cargo_fmt_ok=$(cargo fmt --version &> /dev/null && echo "✅" || echo "❌")
        cargo_clippy_ok=$(cargo clippy --version &> /dev/null && echo "✅" || echo "❌")
        echo "${GREEN}${cargo_fmt_ok} Cargo fmt status${RESET}"
        echo "${GREEN}${cargo_clippy_ok} Cargo clippy status${RESET}"
    fi
else
    echo "${BLUE}Some Rust tools not found in PATH, checking if manual symlinks are needed...${RESET}"
    
    # Check if tools exist in the toolchain but not in ~/.cargo/bin
    if rustup which cargo &> /dev/null; then
        echo "${BLUE}Creating symlinks for Rust tools in ~/.cargo/bin${RESET}"
        
        # Ensure ~/.cargo/bin directory exists
        mkdir -p ~/.cargo/bin
        
        # Create symlinks for main tools
        ln -sf "$TOOLCHAIN_PATH/bin/cargo" ~/.cargo/bin/cargo
        ln -sf "$TOOLCHAIN_PATH/bin/rustc" ~/.cargo/bin/rustc
        ln -sf "$TOOLCHAIN_PATH/bin/rustfmt" ~/.cargo/bin/rustfmt
        ln -sf "$TOOLCHAIN_PATH/bin/clippy-driver" ~/.cargo/bin/clippy-driver
        
        # Create cargo subcommand symlinks
        for cmd in cargo-fmt cargo-clippy; do
            if [ -f "$TOOLCHAIN_PATH/bin/$cmd" ]; then
                ln -sf "$TOOLCHAIN_PATH/bin/$cmd" ~/.cargo/bin/$cmd
            fi
        done
        
        echo "${GREEN}✅ Created Rust tool symlinks${RESET}"
        echo "${GREEN}✅ Rust setup complete - $(rustc --version)${RESET}"
        echo "${GREEN}✅ Cargo available - $(cargo --version)${RESET}"
        echo "${GREEN}✅ Rustfmt available - $(rustfmt --version)${RESET}"
        
        if cargo fmt --version &> /dev/null && cargo clippy --version &> /dev/null; then
            echo "${GREEN}✅ Cargo fmt and clippy available${RESET}"
        else
            cargo_fmt_ok=$(cargo fmt --version &> /dev/null && echo "✅" || echo "❌")
            cargo_clippy_ok=$(cargo clippy --version &> /dev/null && echo "✅" || echo "❌")
            echo "${GREEN}${cargo_fmt_ok} Cargo fmt status${RESET}"
            echo "${GREEN}${cargo_clippy_ok} Cargo clippy status${RESET}"
        fi
    else
        echo "${RED}❌ Rust tools not found after setup${RESET}"
    fi
fi

echo "${GREEN}Ensuring required cargo packages are installed${RESET}"

# Check if mdbook-admonish is installed
if ! cargo install --list | grep -q "^mdbook-admonish"; then
  echo "${BLUE}Installing mdbook-admonish...${RESET}"
  cargo install mdbook-admonish
else
  echo "${GREEN}mdbook-admonish is already installed${RESET}"
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
  "hedge-ops/people"
  "hedge-ops/cloud"
  "hedge-ops/website"
  "hedge-ops/homebrew-tap"
  "hedge-ops/people-work-releases"
  "hedge-ops/people-work-demo-workspace"
  "hedge-ops/vscode-pwl"
  "hedge-ops/apple-certs"
  "hedge-ops/tree-sitter-pwl"
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

cd "$CURRENT_DIR" || exit

echo "${GREEN}Done!${RESET}"