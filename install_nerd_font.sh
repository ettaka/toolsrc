#!/usr/bin/env bash
set -e

FONT_NAME="JetBrainsMono"
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Downloading latest $FONT_NAME Nerd Font release..."
curl -fLO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"

echo "Extracting font files..."

if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
    echo "Termux environment detected."
    FONT_DIR="$HOME/.termux"
    mkdir -p "$FONT_DIR"
    
    # Extract to temporary folder first to find the Regular Nerd Font Mono or regular ttf
    unzip -q "${FONT_NAME}.zip"
    
    # Termux typically uses a single font file named font.ttf
    FONT_FILE=$(find . -name "${FONT_NAME}NerdFontMono-Regular.ttf" -o -name "${FONT_NAME}NerdFont-Regular.ttf" -o -name "*.ttf" | head -n 1)
    
    if [ -n "$FONT_FILE" ]; then
        cp "$FONT_FILE" "$FONT_DIR/font.ttf"
        echo "Font installed to $FONT_DIR/font.ttf"
    else
        echo "Error: Could not find a suitable TTF file in the archive."
        exit 1
    fi

    if command -v termux-reload-settings &> /dev/null; then
        echo "Reloading Termux settings..."
        termux-reload-settings
    else
        echo "Please restart your Termux session or apply the font in Termux styling."
    fi
else
    FONT_DIR="$HOME/.local/share/fonts/nerd-fonts-$FONT_NAME"
    mkdir -p "$FONT_DIR"
    unzip -q "${FONT_NAME}.zip" -d "$FONT_DIR"
    
    echo "Updating font cache..."
    if command -v fc-cache &> /dev/null; then
        fc-cache -f -v
    fi
    echo "Done! '${FONT_NAME} Nerd Font' has been successfully installed."
    echo "Please configure your terminal emulator to use '${FONT_NAME} Nerd Font' or '${FONT_NAME} Nerd Font Mono'."
fi

echo "Cleaning up..."
cd ~
rm -rf "$TEMP_DIR"
