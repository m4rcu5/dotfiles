#!/bin/sh

# Redirect errors to a file in the home directory
errfile="$HOME/.xsession-errors"
if ( umask 077 && cp /dev/null "$errfile" 2> /dev/null ); then
    exec > "$errfile" 2>&1
fi
unset errfile

# Load Xresources file
if [ -f $HOME/.Xresources ]; then
    xrdb -merge $HOME/.Xresources
fi

# Set XDG_* desktop variables
export XDG_SESSION_DESKTOP=i3
export XDG_CURRENT_DESKTOP=i3

# Export default XDG config home
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Qt HiDPI (https://doc.qt.io/qt-6/highdpi.html)
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_SCALE_FACTOR_ROUNDING_POLICY=PassThrough

# Export GTK theme for use in QT5
export QT_QPA_PLATFORMTHEME=gtk2

# GTK3 apps try to contact org.a11y.Bus. Disable that.
export NO_AT_BRIDGE=1

# Update systemd user environment
VARIABLES="HOST DISPLAY XAUTHORITY NO_AT_BRIDGE"
VARIABLES="${VARIABLES} $(printenv | awk -F= '/^XDG_|QT_/ { print $1 }')"
systemctl --user import-environment $VARIABLES

# Update DBus activation environment
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment $VARIABLES
fi

# Spawn D-Bus user session
if (command -v dbus-launch >/dev/null 2>&1) && [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

# Spawn session wide ssh-agent
if (command -v keychain >/dev/null 2>&1); then
    eval $(keychain --eval --noask --quiet --agents ssh)
fi

# Start the X session target
systemctl --user start xsession.target

# Exec the window manager
exec i3
