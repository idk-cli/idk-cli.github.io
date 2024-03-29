#!/bin/bash

# URL of the zip file containing all versions of the script
LATEST_VERSION=$(curl -s "https://api.github.com/repos/idk-cli/idk-cli.github.io/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

ZIP_URL="https://github.com/idk-cli/idk-cli.github.io/archive/refs/tags/$LATEST_VERSION.zip"

# The alias name you want to use to run your script
ALIAS_NAME="idk"

# Temporary directory for downloading and extracting the zip file
TEMP_DIR="/tmp/script_download"
mkdir -p "$TEMP_DIR"

# Detect OS and Architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

# Function to determine the executable name based on OS and Architecture
determine_executable_name() {
    case "$OS" in
        Linux)
            case "$ARCH" in
                arm*|aarch64)
                    echo "idk-linux-amd64"
                    ;;
                x86_64)
                    echo "idk-linux-armv7"
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

# Download the zip file
curl -q --fail --location --progress-bar --output "$TEMP_DIR/scripts.zip" "$ZIP_URL"

# Extract the zip file
unzip -o "$TEMP_DIR/scripts.zip" -d "$TEMP_DIR"

# Determine the executable name
EXECUTABLE_NAME=$(determine_executable_name)

BINNAME="${BINNAME:-idk}"
BINDIR="${USRBINDIR:-/usr/local/bin}"

# Move the appropriate executable to /usr/local/bin (requires sudo)
sudo chmod +x "$TEMP_DIR/idk-cli.github.io-$LATEST_VERSION/assets/$EXECUTABLE_NAME"
sudo mv "$TEMP_DIR/idk-cli.github.io-$LATEST_VERSION/assets/$EXECUTABLE_NAME" "$BINDIR/$BINNAME"

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo ""
echo "------------------------------"
echo "IDK Installation Completed"
echo "------------------------------"
echo ""
