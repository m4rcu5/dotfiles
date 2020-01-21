#!/bin/sh

set -eu

# This script is intended to be run as the xautolock locker and notifier.
# It requires i3lock, and dunst is optional.

# Is the screen already locked?
locked() { pkill -0 --euid "$(id -u)" --exact i3lock; }

# Return 0 if suspend is acceptable.
suspend_ok() {
  # Check if there is any audio playing, indicating activity.
  if [ $(grep -r "RUNNING" /proc/asound | wc -l) -ne 0  ]; then
    return 1
  fi

  # Check if we are running on battery power.
  if [ $(cat /sys/class/power_supply/AC/online) -eq 1 ]; then
    return 1
  fi

  # No reason to defer
  return 0
}

# Print the given message with a timestamp.
info() { printf '%s\t%s\n' "$(date)" "$*"; }

# Notify using notify-send (dunst)
notify() {
  notify-send --urgency="normal" --app-name="xautolock" \
    --icon="system-lock-screen" -- "$*"
}

# Control the dunst daemon, if it is running.
dunst() {
  pkill -0 --exact dunst || return 0

  case ${1:-} in
    stop)
      info "Stopping notifications and locking screen."
      pkill -USR1 --euid "$(id -u)" --exact dunst
      ;;
    resume)
      info "...Resuming notifications."
      pkill -USR2 --euid "$(id -u)" --exact dunst
      ;;
    *)
      echo "dunst argument required: stop or resume"
      return 1
      ;;
  esac
}

case "$1" in
  lock)
    dunst stop

    # Fork both i3lock and its monitor to avoid blocking xautolock.
    i3lock --ignore-empty-password --show-failed-attempts \
      --image="$XDG_CONFIG_HOME/assets/lockscreen.png" --nofork &

    pid="$!"
    info "Waiting for PID $pid to end..."
    while 2>/dev/null kill -0 "$pid"; do
      sleep 1
    done

    dunst resume
    ;;

  notify)
    # Notification should not be issued while locked even if dunst is paused.
    locked && exit

    info "Sending notification."
    # grep finds either Xautolock.notify or Xautolock*notify
    secs="$(xrdb -query | grep -m1 '^Xautolock.notify' | cut -f2)"
    test -n "$secs" && secs="Locking in $secs seconds"

    notify "Screen Lock" "$secs"
    ;;

  suspend)
    if suspend_ok; then
      info "Suspending system."
      systemctl suspend
    else
      info "Deferring suspend."
    fi
    ;;

  disable)
    info "Disabling xautolock."
    notify "Screen Lock" "Automatic locking disabled"

    xautolock -disable
    ;;

  enable)
    info "Enabling xautolock"
    notify "Screen Lock" "Automatic locking enabled"

    xautolock -enable
    ;;

  *)
    info "Unrecognized option: $1"
esac
