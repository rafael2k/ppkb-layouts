#!/bin/sh

if [ ! -d /usr/local/share/kbd/keymaps/ ]; then
    echo "Directory does not exist, creating..."
    mkdir -vp /usr/local/share/kbd/keymaps/
fi

echo "Copying files:"
cp -v kbd/* /usr/local/share/kbd/keymaps/
