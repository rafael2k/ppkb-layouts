#!/bin/sh

echo "Copying files:"
cp -v xkb/pp /usr/share/X11/xkb/symbols/
cp -v xkb/pp-driver /usr/share/X11/xkb/symbols/
cp -v xkb/evdev.xml /usr/share/X11/xkb/rules/
cp -v xkb/evdev.xml /usr/share/X11/xkb/rules/base.xml
cp -v xkb/evdev.lst /usr/share/X11/xkb/rules/
cp -v xkb/evdev.lst /usr/share/X11/xkb/rules/base.lst
