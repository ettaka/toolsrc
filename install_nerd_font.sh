#!/usr/bin/env bash
set -e

FONT_NAME="JetBrainsMono"
FONT_DIR="$HOME/.local/share/fonts/nerd-fonts-$FONT_NAME"

echo "Creating font directory..."
mkdir -p "$FONT_DIR"

echo "Downloading latest $FONT_NAME Nerd Font release..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

curl -fLO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"

echo "Extracting font files..."
unzip -q "${FONT_NAME}.zip" -d "$FONT_DIR"

echo "Cleaning up..."
cd ~
rm -rf "$TEMP_DIR"

echo "Updating font cache..."
fc-cache -f -v

echo "Done! '${FONT_NAME} Nerd Font' has been successfully installed."
echo "Please configure your terminal emulator to use '${FONT_NAME} Nerd Font' or '${FONT_NAME} Nerd Font Mono'."
