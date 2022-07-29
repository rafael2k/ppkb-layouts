# ppkb-layouts

Some keyboard layouts for the PinePhone Keyboard Case to use it as intended or to go beyond into the realm of custom layouts.

## Content

1. [Introduction](#introduction)
1. [Installing Layouts](#installing-layouts)
	1. [xkb](#xkb)
	2. [kbd](#kbd)
	3. [Userspace Driver](#userspace-driver)
	4. [Kernel Driver](#kernel-driver)
		1. [Compiling the Kernel](#compiling-the-kernel)
		2. [As a Module](#as-a-module)
2. [Layouts](#layouts)
	1. [xkb/kbd-Only Layouts](#xkb-kbd-only-layouts)
		1. [AltGr/Pine](#altgr-pine)
		2. [FnSymbols-AltGrF12/FnSymbols-PineF12](#fnsymbols-altgrf12-fnsymbols-pinef12)
		3. [DE-AltGr](#de-altgr)
		4. [DE-Pine](#de-pine)
	2. [Driver-Only Layouts](#driver-only-layouts)
		1. [Extended-Simple](#extended-simple)
	3. [Full Layouts](#full-layouts)
		1. [Extended-AltGr/Pine](#extended-altgr-pine)
		2. [Mirrored](#mirrored)
		3. [Mirrored-WASD](#mirrored-wasd)
		4. [DE-Mirrored](#de-mirrored)
		5. [DE-Mirrored-WASD](#de-mirrored-wasd)
		6. [Phalio](#phalio)
4. [Customising Layouts](#customising-layouts)
	1. [Introduction](#introduction-1)
	2. [xkb](#xkb-1)
	3. [kbd](#kbd-1)
	4. [Userspace Driver](#userspace-driver-1)
	5. [Kernel Driver](#kernel-driver-1)
5. [Troubleshooting](#troubleshooting)
	1. [Stuck (Modifier) Keys](#stuck-modifier-keys)

## Introduction
**I especially recommend the [mirrored](#mirrored) layouts for thumb-only handheld typing that add a second set of modifier keys on the right side of the keyboard. If you don’t want anything fancy and just some additional useful things, the [AltGr/Pine](#altgr-pine) layouts, or if you need PageUp/Down the [Extended-Simple](#extended-simple)/[Extended](#extended-altgr-pine) layouts, are a good choice.**

**All layouts were thoroughly tested in every possible modifier combination and in both GUIs and TTYs, but only partly tested after I added support for modified kernel drivers, which required significant changes. It is possible that some key(combination)s don’t work that should work. Please report such occurrences so that they can be fixed.**

**Also note that the userspace input driver is currently not working with kernels 5.17 and 5.18. If you’re on one of these versions, you’ll have to use a layout that does [not require the userspace driver](#xkb-kbd-only-layouts) or compile your own [modified kernel driver](#kernel-driver).**

## Installing Layouts

Layouts may consist of xkb, kbd or driver components. xkb defines symbols for graphical environments and kbd defines symbols for TTYs. If you only use graphical environments, you may omit the TTY part or vice versa. Driver components influence both environments and are usually combined with xkb and kbd components for full customisability. Each layout includes a list of its components that have to be installed to use the layout.

### xkb

To install and use an xkb layout, you have to copy xkb files to certain directories and then tell your system what layout to use.

#### Copying Files

Copying the xkb files can simple be done by using the `install-xkb.sh` script that comes with this repository. It has to be executed with sudo, so check what it does first. To copy the files manually instead, you have to copy `xkb/pp` and `xkb/pp-usrspc` to `/usr/share/X11/xkb/symbols/`, as well as `xkb/evdev.xml` to both `/usr/share/X11/xkb/rules/evdev.xml` and `/usr/share/X11/xkb/rules/base.xml`, and `xkb/evdev.lst` to both `/usr/share/X11/xkb/rules/evdev.lst` and `/usr/share/X11/xkb/rules/base.lst`.

This will only add the pp and pp-usrspc layout files, so it won’t override any other custom layouts you may have. It will however override any custom entries in evdev.

#### Selecting Layout

xkb is what manages keyboard layouts in graphical environments by default, so there should be ways integrated within your GUI to change it or search engine results that tell you how to do it for your system. If you use systemd, you can simply use `localectl set-x11-keymap <layout> pc105 <variant>`. Substitute `<layout>` and `<variant>` with whatever you want to use, e.g. `localectl set-x11-keymap pp pc105 altgr`. Despite the name, this works for both X11 and Wayland. If you use Sxmo/Sway, you can also put the following lines into your Sway config `~/.config/sxmo/sway`:

```
input * {
    xkb_layout "pp"
    xkb_variant "altgr"
}
```

### kbd

To install and use a kbd layout, you may optionally copy the keymap file somewhere, and you have to tell your system to use it.

#### Copying Files

It seems to be good practice to put the keymaps into `/usr/local/share/kbd/keymaps/`. This can simply be done by using the `install-kbd.sh` script that comes with this repository. It has to be executed with sudo, so check what it does first. To copy the files manually instead, you have to copy the keymaps (or only the one you need) from `kbd/` to `/usr/local/share/kbd/keymaps/`.

#### Selecting Layout

To set a permanent layout, use `sudo nano /etc/vconsole.conf` and add the line `KEYMAP=/usr/local/share/kbd/keymaps/ppkb-altgr.map`. Use the path and file name of the layout you want to use.

To immediately set a layout that will not persist after a reboot, use either `sudo loadkeys /usr/local/share/kbd/keymaps/ppkb-altgr.map` from within your TTY, or via GUI/SSH use either `sudo loadkeys -C /dev/console -d /usr/local/share/kbd/keymaps/ppkb-altgr.map` or become root with `sudo su` and use `loadkeys /usr/local/share/kbd/keymaps/ppkb-altgr.map`, depending on what works. For me, the former worked on Arch Sxmo and the latter on Manjaro Plasma Mobile. Doing it this way may fail if the layout contains unsupported symbols, but it will always work with the vconsole.conf file.

### Userspace Driver

To use a layout requiring the userspace driver, you have to download the driver, copy the keymap file to it, compile the driver with the keymap and start it.

#### 1. Download

First, in the directory of your choice, clone Megi’s repository by using `git clone https://megous.com/git/pinephone-keyboard`.

#### 2. Keymap File

The key definitions are located in the file `keymaps/factory-keymap.txt`. You can simply override the content of this file with any other keymap by using e.g. `cp ~/git/ppkb-layouts/userspace-driver/extended.txt ~/git/pinephone-keyboard/keymaps/factory-keymap.txt`. Replace the paths and desired keymap with yours.

#### 3. Compiling

To compile you must be in the `pinephone-keyboard` directory and simply use `make`. You may need to install `make`, `gcc`  and `php` first if you don’t have them.

#### 4. Disabling Kernel Driver Input

Kernel driver keyboard input and userspace driver keyboard input cannot be active at the same time. To use the userspace driver, the input part of the PPKB kernel driver has to be disabled. The kernel driver has been renamed with the newer version, so if you are still on the old version where Fn+numRow prints symbols, replace `pinephone-keyboard.disable_input` in the following instructions with `kb151.disable_input`. You have to add this parameter to the kernel arguments.

**On Manjaro**, edit `sudo nano /boot/boot.txt` and at the end of the line starting with “setenv bootargs”, add `pinephone-keyboard.disable_input`. Then use `sudo pp-uboot-mkscr` and reboot.

**On Arch**, go to `cd /boot`, edit `sudo nano boot.txt` and at the end of the line starting with “setenv bootargs”, add `pinephone-keyboard.disable_input`. Then use `sudo ./mkscr` and reboot.

#### 5. Starting the Userspace Driver

The executable for the keyboard input part is `build/ppkb-i2c-inputd`. To run it temporarily, simply execute it with sudo. This will print the keyboard matrix to the terminal for any key you press. To have it active at all times in the background, use e.g. a systemd service as described in the next paragraph.

**To create a systemd service**, use `sudo nano /etc/systemd/system/ppkb-inputd.service` and paste the following lines (adjust the path to ppkb-i2c-inputd to fit yours):

```
[Unit]
Description=PinePhone Keyboard userspace daemon

[Service]
Type=simple
ExecStart=/home/phalio/git/pinephone-keyboard/build/ppkb-i2c-inputd
Restart=on-failure
RestartSec=10
KillMode=process

[Install]
WantedBy=multi-user.target
```

Start the service with `sudo systemctl enable --now ppkb-inputd.service`.

#### Changing the Layout again

Remember, each time you want to use a different layout or have made changes to a layout, you have to not only copy the keymap again but also compile it again (steps 2 and 3). And restart the inputd service if you want a quicker way than rebooting, e.g. `sudo systemctl restart ppkb-inputd.service`.

### Kernel Driver

#### Explanation

For Full layouts, there are two options for modified kernel input drivers: `pinephone-keyboard-full` and `pinephone-keyboard-full-improved`. Both let you type the same symbols of the selected layout, just like the userspace driver. But they still have differences that could be important or vital. `pinephone-keyboard-full` allows you to use the pine key entirely as normal, even if pressed by itself, unlike the userspace driver. It also works even while the userspace driver is broken (as it has been for quite a while, as of 2022-07-25). `pinephone-keyboard-full-improved` (as well as any `*-improved`) on the other hand fully removes the Fn layer and replaces it with regular modifiers, thereby removing the very annoying behaviour of getting keys stuck if Fn is not let go of last. That makes this the best and most comfortable option, at the cost of more difficult installation and maintaining, as well as losing the ability to send raw scan codes for e.g. F1-12 and arrow keys, which also means that the GUI (not TTY) keyboard shortcut to switch to TTY won’t work. You can always define a regular shortcut in your desktop environment or use `chvt`, but that won’t work if the GUI is frozen and you have no SSH access. Still, at least in my opinion that is a small price to pay for a perfecttly working custom keyboard layout.

#### Introduction

If you’re familiar with kernel stuff, simply apply the appropriate patch or layout file from `kernel-driver/` to the `pinephone-keyboard` keyboard input kernel driver.

This is my first time doing anything with the kernel, so this section might not be that helpful/correct, but it worked for me™. First, check if your installed kernel has the keyboard driver as a loadable module, allowing you to edit it on the fly, by using `lsmod`. If `pinephone-keyboard` appears in the list, you can skip the next section about compiling and installing the entire kernel and go to [As a Module](#as-a-module). If not, you have to compile the kernel yourself.

#### Compiling the Kernel

If you have a device that is faster than the PinePhone (Pro), you might want to cross-compile on that device instead. To do so, install the appropriate package for your distro as described [here](https://wiki.pine64.org/wiki/Cross-compiling#Installing_the_Toolchain). The following describes how to compile a modified Megi kernel as used in Arch, on Arch. Install `base-devel` if you haven’t already. Replace the path to the patch file with yours and your desired patch file.

```
git clone https://github.com/dreemurrs-embedded/Pine64-Arch.git
cd Pine64-Arch/PKGBUILDS/pine64/linux-megi/
cp ~/code/git/ppkb-layouts/kernel-driver/pinephone-keyboard-full.patch ./
```

Edit the PKGBUILD and insert `'pinephone-keyboard-full.patch'` in the `# PinePhone Patches` section.

Optionally, but highly suggested, edit the config file and set `CONFIG_KEYBOARD_PINEPHONE=m` which will make the driver a loadable module, allowing you to change it at any time without having to recompile the entire kernel.

If you cross-compile, replace each invocation of `make` in the PKGBUILD with `make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-` and `strip` with `aarch64-linux-gnu-strip`. Also execute  `export CARCH=aarch64`.

```
makepkg -g >> PKGBUILD
makepkg -s
```

If you compile on the PinePhone itself, you can use `makepkg -si` instead which will compile and also install it, allowing you to skip the following pacman commands.

Compiling could take a while. Once done, if you cross-compiled, move everything or just the following files to the PinePhone and `cd` into the same directory or wherever you put the compiled files. Then install with pacman:

```
sudo pacman -U ./linux-megi-5.18.7-1-aarch64.pkg.tar.zst
sudo pacman -U ./linux-megi-headers-5.18.7-1-aarch64.pkg.tar.zst
```

Reboot and you will be running your own custom kernel with a custom keyboard layout! One that you can edit without having to re-compile the entire kernel! See the next section for how to edit the driver once it’s installed as a loadable module.

#### As a Module

First, clone the kernel repository if you don’t have it already. In this example I will be using Megi’s kernel. The version must exactly match your current kernel or you will not be able to install the compiled kernel module.

```
git clone --depth=1 -b orange-pi-5.18 https://github.com/megous/linux
wget https://github.com/megous/linux/archive/13dcfc7cc0b10ed0b6b77d9be55481f491fc4c10.tar.gz
tar -xvf 13dcfc7cc0b10ed0b6b77d9be55481f491fc4c10.tar.gz
```

If you don’t have `base-devel`, install it with your package manager.

```
wget https://raw.githubusercontent.com/dreemurrs-embedded/Pine64-Arch/master/PKGBUILDS/pine64/linux-megi/config
mv config .config
nano include/generated/utsrelease.h
```

Edit the version to exactly match yours (the `uname -r` output), including additional numbers, letters or symbols after the version number.

```
cd drivers/input/keyboard/
mv Makefile Makefile.bak
nano Makefile
```

Add the following text (replace the path with yours):

```
obj-m = pinephone-keyboard.o
all:
        make -C /home/alarm/code/git/linux-13dcfc7cc0b10ed0b6b77d9be55481f491fc4c10 M=$(PWD) modules
clean:
        make -C /home/alarm/code/git/linux-13dcfc7cc0b10ed0b6b77d9be55481f491fc4c10 M=$(PWD) clean
```

Apply the desired patch by using `git apply ~/code/git/ppkb-layouts/kernel-driver/pinephone-keyboard-full-improved.patch`. If you want to restore the original, use `git checkout -- pinephone-keyboard.c`.

Compile the driver by executing `make`.

If you just want to quickly and temporarily test it, use these commands:

```
sudo rmmod pinephone-keyboard
sudo insmod ./pinephone-keyboard.ko
```

To set it permanently, find out where the current module is located with `modinfo`, copy the new module to the path it gives you, cd to the directory, compress the module, unload the old one, load the new one and rebuild your initramfs to make it persist after reboots:

```
modinfo pinephone-keyboard
sudo cp pinephone-keyboard.ko /lib/modules/5.18.7-1-phalio/kernel/drivers/input/keyboard/
cd /lib/modules/5.18.7-1-phalio/kernel/drivers/input/keyboard/
sudo mv pinephone-keyboard.ko.xz pinephone-keyboard.ko.xz.old
sudo xz pinephone-keyboard.ko
sudo rmmod pinephone-keyboard
sudo modprobe pinephone-keyboard
sudo mkinitcpio -P
```

The used kernel driver is now updated!

## Layouts

All layouts also feature a compose key, usually on an additional layer of the Tab key. This key allows to print a wide variety of symbols by combining multiple symbols typed after it, e.g. `Compose` `´`+`e` prints `é`, `Compose` `^`+`1` prints `¹` and much more.

## xkb/kbd-Only Layouts

These layouts are limited in what they can do (specifically they cannot add an Fn-layer to any key that doesn’t have one by default) but they are the simplest to install as they only require putting the xkb and/or kbd files into the right spot and using a command. They also require the new kernel driver, the one where Fn+numRow results in F1-F10. If you’re still on an older kernel version where these key combinations print extra symbols like |\£, you have to use a layout from the other categories.

Optionally, you may use them with the `regular-improved` kernel driver to prevent Fn from getting keys stuck if not released last.

### AltGr/Pine

![Keyboard layout AltGr/Pine](img/pp-altgr-pine.svg)

These layouts are intended to be simple and just do two things: They make the extra symbols on the number row accessible using either AltGr or the Pine key and they add more symbols for international compatibility. F11 and F12 are also added just because there was space but on different layers due to F1-10 and Del being on the same layer by default and this layout not intending to change any default mapping.

#### Installation Requirements

xkb: layout: `pp`, variants: `altgr` or `pine`  
tty: `ppkb-altgr.map` or `ppkb-pine.map`

### FnSymbols-AltGrF12 / FnSymbols-PineF12

![Keyboard layout FnSymbols-AltGrF12 / FnSymbols-PineF12](img/pp-fnsymbols-altgrf12-fnsymbols-pinef12.svg)

These layouts are the same as [AltGr/Pine](#altgr-pine) but they swap the number row extra layer keys, so they use the Fn key for extra number row symbols and AltGr or Pine for F1-F12, just like the old kernel driver did.

#### Installation Requirements

xkb: layout: `pp`, variants: `fnsymbols-altgrf12` or `fnsymbols-pinef12`  
tty: `ppkb-fnsymbols-altgrf12.map` or `ppkb-fnsymbols-pinef12.map`

### DE-AltGr

![Keyboard layout DE-AltGr](img/pp-de-altgr.svg)

This layout intends to recreate the standard German QWERTZ layout, including placement of symbols. Symbols from missing keys are put on unused third layers of the number row, in the same spot as the symbols printed on the keycaps if possible. The extra letters “ÄÖÜ” are placed on dedicated keys at the bottom right while ß is on the third layer of S. The [DE-Pine](#de-pine) layout is an alternative version of this one that uses the Pine key for the third layer, freeing the AltGr key to be used as another dedicated key for ß. F11 and F12 are also added just because there was space but on different layers due to F1-10 and Del being on the same layer by default and this layout not intending to change any default mapping other than German-specific things.

#### Installation Requirements

xkb: layout: `pp`, variant: `de-altgr`  
tty: `ppkb-de-altgr.map`

### DE-Pine

![Keyboard layout DE-Pine](img/pp-de-pine.svg)

This layout is the same as [DE-AltGr](#de-altgr) but it uses the Pine key for the third layer, freeing the AltGr key to be used as another dedicated key for ß. This means that all additional letters of the German alphabet, ÄÖÜß, have dedicated keys.

#### Installation Requirements

xkb: layout: `pp`, variant: `de-pine`  
tty: `ppkb-de-pine.map`

## Driver-Only Layouts

These layouts are limited in what they can do as they only change hardware key codes, but that means only one component is required to make them work in both GUIs and TTYs.

### Extended-Simple

![Keyboard layout Extended-Simple](img/pp-usrspc-extended-simple.svg)

This layout is intended to be simple and does only two tings: It adds the additional number row symbols using the Fn as modifier, as well as extending the layout to include some missing keys that some might find important, specifically by adding F11 (commonly used to toggle full screen) on Backspace with the Pine key as modifier and PageUp/Down on P and ; with Fn, moving Insert from ; to Enter.

F12 is not added even though there are 12 keys in the top row because using the userspace driver’s special modifier keys Fn and Pine in combination with the Esc key activates Fn/Pine Lock (like Caps Lock), redefining these additional Esc levels is not possible with a keymap.

[Extended-AltGr/Pine](#extended-altgr-pine) are “advanced” versions of this layout that add international symbols and F12, therefore also requiring an xkb/kbd component.

#### Installation Requirements

Userspace driver: `extended-simple.txt`

## Full Layouts

These layouts require both a driver component and an xkb and/or kbd component and allow full customisation.

### Extended-AltGr-Pine

![Keyboard layout Extended-AltGr/Pine](img/pp-usrspc-extended-altgr-pine.svg)

This layout adds the additional number row symbols using the AltGr as modifier, as well as extending the layout to include some missing keys that some might find important, specifically by adding F11 and F12 and PageUp/Down on P and ;, moving Insert from ; to Enter and Del to the AltGr layer. It also adds international symbols on additional layers.

#### Installation Requirements

xkb: layout: `pp-usrspc`, variants: `extended-altgr` or `extended-pine`  
tty: `ppkb-extended-altgr.map` or `ppkb-extended-pine.map`  
Userspace driver: `full.txt`

### Mirrored

![Keyboard layout Mirrored](img/pp-usrspc-mirrored.svg)

This layout provides mirrored modifier keys, meaning that both left and right versions of Shift, Control, Fn and Alt exist. This is very useful for thumb-only handheld typing as it allows you to e.g. press RightShift with your right thumb and Q with your left thumb to type a capital Q instead of having to press both LeftShift and Q on the left side, which would require partially letting go of the device with either hand, unless your thumbs are twice as long as mine. It also expands key definitions by F11 F12, PageUp/Down and international symbols.

Since the right versions of Fn, Ctrl and Shift also double as the movement keys ◄ ▼ ► if any Fn is held, it’s not possible to combine any Fn and right Ctrl or Shift. For example, combining any Fn and right Shift to access the fourth layer does not work since LFN+RShift results in ►. Use RFN+LShift (thumb-only-friendly) or LFn+LShift or RFn+RShift instead. If you want right modifier keys that are dedicated and work in any combination, consider using [Mirrored-WASD](#mirrored-wasd) instead which moves the navigation keys to the WASD area.

#### Installation Requirements

xkb: layout: `pp-usrspc`, variant: `mirrored`  
tty: `ppkb-mirrored.map`  
Userspace driver: `full.txt`

### Mirrored-WASD

![Keyboard layout Mirrored-WASD](img/pp-usrspc-mirrored-wasd.svg)

This layout moves the arrow keys, home/end and pageup/down to WASD QE RF. Like regular [Mirrored](#mirrored), it also  provides mirrored modifier keys, meaning that both left and right versions of Shift, Control, Fn and Alt exist. This is very useful for thumb-only handheld typing as it allows you to e.g. press RightShift with your right thumb and Q with your left thumb to type a capital Q instead of having to press both LeftShift and Q on the left side, which would require partially letting go of the device with either hand, unless your thumbs are twice as long as mine. It also expands key definitions by F11 F12 and international symbols.

#### Installation Requirements

xkb: layout: `pp-usrspc`, variant: `mirrored-wasd`  
tty: `ppkb-mirrored-wasd.map`  
Userspace driver: `full.txt`

### DE-Mirrored

![Keyboard layout DE-Mirrored](img/pp-usrspc-de-mirrored.svg)

This layout provides mirrored modifier keys, meaning that both left and right versions of Shift, Control, Fn and Alt exist. This is very useful for thumb-only handheld typing as it allows you to e.g. press RightShift with your right thumb and Q with your left thumb to type a capital Q instead of having to press both LeftShift and Q on the left side, which would require partially letting go of the device with either hand, unless your thumbs are twice as long as mine. It also expands key definitions by F11 F12, PageUp/Down and international symbols. It also expands key definitions by F11 F12, PageUp/Down and international symbols.

Besides that, this layout intends to recreate the standard German QWERTZ layout, including placement of symbols. Symbols from missing keys are put on unused third layers of the number row, in the same spot as the symbols printed on the keycaps if possible. Unlike the normal [DE](#de-altgr) layouts, this one puts the extra letters “ÄÖÜß” on the Fn layer of AOUS.

Since the right versions of Fn, Ctrl and Shift also double as the movement keys ◄ ▼ ► if Fn is held, it’s not possible to combine any Fn and right Ctrl or Shift. For example, combining any Fn and right Shift to access the fourth layer does not work since LFN+RShift results in ►. Use RFN+LShift (thumb-only-friendly) or LFn+LShift or RFn+RShift instead. If you want right modifier keys that are dedicated and work in any combination, consider using [DE-Mirrored-WASD](#de-mirrored-wasd) instead which moves the navigation keys to the WASD area.

#### Installation Requirements

xkb: layout: `pp-usrspc`, variant: `de-mirrored`  
tty: `ppkb-de-mirrored.map`  
Userspace driver: `full.txt`

### DE-Mirrored-WASD

![Keyboard layout DE-Mirrored-WASD](img/pp-usrspc-de-mirrored-wasd.svg)

This layout moves the arrow keys, home/end and pageup/down to WASD QE RF. Like regular [DE-Mirrored](#de-mirrored), it also provides mirrored modifier keys, meaning that both left and right versions of Shift, Control, Fn and Alt exist. This is very useful for thumb-only handheld typing as it allows you to e.g. press RightShift with your right thumb and Q with your left thumb to type a capital Q instead of having to press both LeftShift and Q on the left side, which would require partially letting go of the device with either hand, unless your thumbs are twice as long as mine. It also expands key definitions by F11 F12, PageUp/Down and international symbols. It also expands key definitions by F11 F12 and international symbols.

Besides that, this layout intends to recreate the standard German QWERTZ layout, including placement of symbols. Symbols from missing keys are put on unused third layers of the number row, in the same spot as the symbols printed on the keycaps if possible. Unlike the normal [DE](#de-altgr) layouts, this one puts the extra letters “ÄÖÜß” on the Fn layer. Since A and S are already used by the arrow keys unlike in [DE-Mirrored](#de-mirrored), Ä is placed on I since that’s between Ü and Ö, and ß is placed on P since that’s next to ÄÖÜ and right below the key where it would be on a regular German layout.

#### Installation Requirements

xkb: layout: `pp-usrspc`, variant: `de-mirrored-wasd`  
tty: `ppkb-de-mirrored-wasd.map`  
Userspace driver: `full.txt`

### Phalio

![Keyboard layout Phalio](img/pp-usrspc-phalio.svg)

This layout started with the goal of making it as close to my usual custom layout as possible, of course also adding badly needed PageUp/Down, F11, F12 and lots of other characters and symbols. This also included putting navigational keys in the WASD area, which is probably the best part of my usual layout. While making it I also had a great idea to solve the thumb-only handheld typing issue: Mirrored modifier keys. In this case they’re really useful, unlike on a regular keyboard where I rarely use them. Typing and using shortcuts like in Emacs works wonderfully and smoothly now.

#### Installation Requirements

xkb: layout: `pp-usrspc`, variant: `phalio`  
tty: `ppkb-phalio.map`  
Userspace driver: `phalio.txt`

## Customising Layouts

### Introduction

### xkb

### kbd

### Userspace Driver

### Kernel Driver

## Troubleshooting

### Stuck (Modifier) Keys

Driver-based modifier keys (Fn and, if using the userspace driver, Pine) currently have the unfortunate behaviour of not stopping a key press event when the modifier key is let go of before other keys of a key combination, e.g. holding Fn -> holding W -> releasing Fn -> releasing W will continue to send that W keypress indefinitely until you “un-stuck” the affected key by doing the key combination again and releasing Fn last or just pressing the affected key, depending on what works. You can also get normal modifier keys stuck like this, e.g. holding Fn -> holding Shift -> releasing Fn -> releasing Shift will continue sending the Shift signal, making it impossible to use non-shift layers. If it happens, get it unstuck as just described. To prevent it from happening in the first place, get used to always releasing Fn last, or use a [modified kernel driver](#kernel-driver) (either the one the layout tells you to use or `regular-improved` for the first category of layouts). This removes this bug altogether. `xev` may also help in identifying the stuck key, but unfortunately not always.
