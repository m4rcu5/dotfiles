#!/bin/bash
#
# This script is intended to be called from xss-lock with the '--transfer-sleep-lock' option.
#

set -eu

# notify using notify-send (dunst)
notify() {
  notify-send --urgency="normal" --app-name="xautolock" \
    --icon="system-lock-screen" -- "$*"
}

# control the dunst daemon, if it is running.
dunst() {
  pkill -0 --exact dunst || return 0

  case ${1:-} in
    stop)
      echo "Stopping notifications and locking screen ..."
      pkill -USR1 --euid "$(id -u)" --exact dunst
      ;;
    resume)
      echo "... Resuming notifications."
      pkill -USR2 --euid "$(id -u)" --exact dunst
      ;;
    *)
      echo "dunst argument required: stop or resume"
      return 1
      ;;
  esac
}

case "$1" in
  dim)
    # handle TERM signal
    trap "exit 0" TERM INT

    if $(command -v xbacklight &>/dev/null); then
      # return to current brightness on exit
      trap "xbacklight -fps 30 -set $(xbacklight -get); kill %%" EXIT

      # reduce brightness to 1%
      xbacklight -fps 15 -set 1

      # wait until exit
      sleep infinity &
      wait
    fi
    ;;

  lock)
    # pause any music players
    $(command -v playerctl &>/dev/null) && playerctl -a pause

    # pause dunst notifications
    dunst stop

    # launch i3lock, it will close the inherited sleep-lock
    i3lock --ignore-empty-password --show-failed-attempts \
      --image="$XDG_CONFIG_HOME/assets/lockscreen.png" --nofork 

    # resume dunst
    dunst resume
    ;;

  *)
    echo "Unrecognized option."
esac
