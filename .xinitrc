#!/bin/sh

# Adjust keyboard typematic delay and rate
xset r rate 250 60

# Merge & load configuration from .Xresources
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
[[ -f ~/.xprofile ]] && . ~/.xprofile

# https://bugs.archlinux.org/task/46374
# shellcheck source=/etc/X11/xinit/xinitrc.d/50-systemd-user.sh
source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

# Firefox hardware video acceleration (VA-API on X11)
export MOZ_X11_EGL=1
export MOZ_DISABLE_RDD_SANDBOX=1
export LIBVA_DRIVER_NAME=iHD

# Let QT autodetect retina screen and autoadjust
export QT_AUTO_SCREEN_SCALE_FACTOR=1
# GTK and Chromium/Electron scaling comes from XSETTINGS, not GDK_SCALE:
# Chromium multiplies GDK_SCALE with the DPI and ends up double size
xsettingsd -c "$XDG_RUNTIME_DIR/xsettingsd.conf" &

# Start xbindkeys
xbindkeys &

# autocutsel &

# Start removable media task tray
udiskie &

# Setup keyboard layout

# Extended keyboard
# setxkbmap -model pc104 -layout gb

# Mac Laptop keyboard
# setxkbmap -layout gb
# Configure ZiYouLang T8 RGB Keyboard
setxkbmap -layout us

# Let the system config handle keyboard layout
# setxkbmap -layout us -variant ""

# Start ssh-agent for SSH keys
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval $(ssh-agent -s)
    # Optionally auto-add your key:
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi

export SSH_AUTH_SOCK

# Optionally start GPG agent if you use it
export GPG_TTY=$(tty)
gpgconf --launch gpg-agent

# dwmstatus 2>&1 >/dev/null &
exec slstatus &
exec dwm

# Clean up when DWM exits
loginctl terminate-session "$XDG_SESSION_ID"
