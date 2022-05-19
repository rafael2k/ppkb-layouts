#!/bin/sh

echo "Copying files:"
cp -v xkb/pp /usr/share/X11/xkb/symbols/
cp -v xkb/pp-usrspc /usr/share/X11/xkb/symbols/
cp -v xkb/evdev.xml /usr/share/X11/xkb/rules/
