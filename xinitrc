#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/Xresources
sysmodmap=/etc/X11/Xmodmap

# merge in defaults and keymaps
[ -f $sysresources ]  && /usr/bin/xrdb -merge $sysresources
[ -f $sysmodmap ]     && /usr/bin/xmodmap $sysmodmap
[ -f $userresources ] && /usr/bin/xrdb -merge $userresources
[ -f $usermodmap ]    && /usr/bin/xmodmap $usermodmap

# include xinitrc scripts
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/* ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# export gtk theme for qt
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# set background
feh --no-fehbg --no-xinerama --bg-fill "$HOME/images/wallpapers/wallpaper.png" &

# start terminal
urxvtd -q -o -f &

# start redshift
[[ $(type redshift) ]] && redshift &

# start xautolock
[[ $(type xautolock) ]] && xautolock -time 10 -detectsleep \
    -locker "pkill -USR1 dunst; i3lock -n --image $HOME/images/wallpapers/lock.png; pkill -USR2 dunst" \
    -notify 20 -notifier "notify-send -a xautolock \"LOCKING screen in in 20s\"" &

# start session
DEFAULT_SESSION=i3

case $1 in
i3)
    exec i3
    ;;
*)
    exec $DEFAULT_SESSION
    ;;
esac
