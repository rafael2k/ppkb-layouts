#!/bin/sh

if [ ! -d /etc/kbct ]; then
    echo "Directory does not exist, creating..."
    mkdir -vp /etc/kbct
fi

echo "Copying files:"
cp -v kbct/* /etc/kbct/
