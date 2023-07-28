if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    # Export session variables
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=sway
    export XDG_CURRENT_DESKTOP=sway

    # Enable Wayland backend in Mozilla products
    export MOZ_ENABLE_WAYLAND=1

    # Eanble Wayland backend in QT applications
    export QT_QPA_PLATFORM=wayland

    # Enable Wayland backend in SDL
    export SDL_VIDEODRIVER=wayland

    # Inform Java that sway is a non-repainting WM
    export _JAVA_AWT_WM_NONREPARENTING=1

    # Export default XDG config home
    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

    # Export GTK theme for use in QT5
    export QT_QPA_PLATFORMTHEME=gtk2

    # Spawn session wide ssh-agent
    if (command -v keychain >/dev/null); then
        eval $(keychain --eval --noask --quiet --agents ssh)
    fi

    # Launch sway and send its output to the journal
    exec systemd-cat --identifier=sway sway
fi
