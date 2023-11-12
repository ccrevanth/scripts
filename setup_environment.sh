#!/bin/bash

# Function to display an error message and exit
function display_error() {
  echo "Error: $1"
  exit 1
}

# Function to prompt the user for input (yes/no)
function prompt_yes_no() {
  while true; do
    read -p "$1 (yes/no): " answer
    case $answer in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

# Check if Homebrew is installed on macOS
if [ "$(uname)" == "Darwin" ]; then
  if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || display_error "Failed to install Homebrew."
  fi
fi

# Update and install OpenJDK 8
sudo apt-get update || display_error "Failed to update package list."
sudo apt-get install -y openjdk-8-jdk || display_error "Failed to install OpenJDK 8."

# Install required packages
required_packages="bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32readline-dev lib32z1-dev libelf-dev liblz4-tool libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev"
sudo apt-get install -y $required_packages || display_error "Failed to install required packages."

# Set up git
if ! git config --global user.email "crevanthh@gmail.com"; then
  display_error "Failed to configure git user email."
fi

if ! git config --global user.name "crevanth"; then
  display_error "Failed to configure git username."
fi

# Install Git LFS
git lfs install || display_error "Failed to install Git LFS."

# Check if ccache is already configured
if ! is_ccache_configured; then
  # Ask whether to configure ccache
  if prompt_yes_no "Do you want to configure ccache?"; then
    # Download and set up repo
    mkdir -p ~/bin || display_error "Failed to create ~/bin directory."
    curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo || display_error "Failed to download 'repo'."
    chmod a+x ~/bin/repo || display_error "Failed to make 'repo' executable."
    echo 'export PATH=~/bin:$PATH' >> ~/.bashrc || display_error "Failed to add 'repo' to PATH."
    source ~/.bashrc || display_error "Failed to source ~/.bashrc."

    # Configure ccache with 50GB size and compression enabled
    echo 'export USE_CCACHE=1' >> ~/.bashrc || display_error "Failed to configure USE_CCACHE."
    echo 'export CCACHE_EXEC=/usr/bin/ccache' >> ~/.bashrc || display_error "Failed to configure CCACHE_EXEC."
    ccache -M 50G || display_error "Failed to set ccache size to 50GB."
    echo 'export CCACHE_COMPRESS=1' >> ~/.bashrc || display_error "Failed to configure CCACHE_COMPRESS."
    ccache -o compression=true || display_error "Failed to enable ccache compression."
    source ~/.bashrc || display_error "Failed to source ~/.bashrc."
  else
    echo "Skipping ccache configuration."
  fi
else
  echo "ccache is already configured. Skipping ccache configuration."
fi

echo "Development environment setup complete."
