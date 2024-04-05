#!/bin/bash

SCRIPT_LATEST_VERSION=$(curl -s https://api.github.com/repos/idk-cli/idk_terminal/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
SCRIPT_ZIP_URL="https://github.com/idk-cli/idk_terminal/archive/refs/tags/$SCRIPT_LATEST_VERSION.zip"

# Temporary directory for downloading and extracting the zip file
TEMP_DIR=".idk_script_tmp"
mkdir -p "$TEMP_DIR"

# Temporary zip file name
TEMP_FILE_NAME="idk.zip"

# Detect OS and Architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

INSTALL_DIR="/usr/local/bin"
INSTALL_FILE="idk"

# Function to determine the executable name based on OS and Architecture
determine_executable_name() {
    case "$OS" in
        Linux)
            case "$ARCH" in
                arm*|aarch64)
                    echo "idk-linux-armv7"
                    ;;
                x86_64)
                    echo "idk-linux-amd64"
                    ;;
                *)
                    echo "Unsupported architecture: $ARCH" >&2
                    exit 1
                    ;;
            esac
            ;;
        Darwin)
            case "$ARCH" in
                arm*|aarch64)
                    echo "idk-darwin-arm64"
                    ;;
                x86_64)
                    echo "idk-darwin-amd64"
                    ;;
                *)
                    echo "Unsupported architecture: $ARCH" >&2
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "Unsupported operating system: $OS" >&2
            exit 1
            ;;
    esac
}

echo "Downloading idk.."
curl -q -Lo "$TEMP_DIR/$TEMP_FILE_NAME" "$SCRIPT_ZIP_URL" || wget -O "$TEMP_DIR/$TEMP_FILE_NAME" "$SCRIPT_ZIP_URL"

# # Extract the zip file
unzip -o "$TEMP_DIR/$TEMP_FILE_NAME" -d "$TEMP_DIR" >/dev/null 2>&1

# Determine the executable name
EXECUTABLE_NAME=$(determine_executable_name)

# Move the appropriate executable to /usr/local/bin (requires sudo)
sudo chmod +x "$TEMP_DIR/idk_terminal-$SCRIPT_LATEST_VERSION/binaries/$EXECUTABLE_NAME"
sudo mv "$TEMP_DIR/idk_terminal-$SCRIPT_LATEST_VERSION/binaries/$EXECUTABLE_NAME" "$INSTALL_DIR/$INSTALL_FILE"

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo ""
echo "------------------------------"
echo "IDK Installation Completed"
echo "------------------------------"
echo ""
