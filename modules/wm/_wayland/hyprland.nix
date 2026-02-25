{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) getExe getExe';
  rgba = color: alpha: "rgba(${color}${alpha})";
  term = "${lib.getExe pkgs.foot} -e";
  browser = config.me.wm.browser;
in
lib.mkIf (config.me.wm.displayServer == "wayland") {
  hj.xdg.config.files."zsh/.zshrc".text =
    lib.mkBefore # bash
      ''
        [[ $(tty) == "/dev/tty1" ]] && {
            source ~/.profile
            exec hyprland &> /dev/null
        }
      '';

  programs.hyprland.enable = true;
  hj.xdg.config.files."hypr/hyprland.conf".text = ''
    env = DISPLAY,:0
    env = HYPRLAND_INSTANCE_SIGNATURE,1
    env = WAYLAND_DISPLAY,wayland-1
    env = XDG_CURRENT_DESKTOP,Hyprland

    monitor = , preferred, auto, 1

    general {
      gaps_in = 0
      gaps_out = 0
      border_size = 1
      col.active_border = rgba(33ccffee)
      col.inactive_border = rgba(595959aa)
      layout = dwindle
      no_focus_fallback = true
    }

    decoration {
      rounding = 0
      blur {
        enabled = false
      }
      shadow {
        enabled = false
      }
    }

    animations {
      enabled = false
    }

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
      focus_on_activate = true
      new_window_takes_over_fullscreen = 2
      middle_click_paste = false
      mouse_move_enables_dpms = true
      key_press_enables_dpms = true
    }

    input {
      kb_options = compose:ralt
      repeat_rate = 30
      repeat_delay = 200
      follow_mouse = 2
      float_switch_override_focus = 0
      touchpad {
        natural_scroll = true
      }
    }

    # gestures {
    #   workspace_swipe = true
    #   workspace_swipe_fingers = 3
    # }

    cursor {
      hide_on_key_press = true
    }

    binds {
      movefocus_cycles_fullscreen = false
    }

    ecosystem {
      no_update_news = true
    }

    dwindle {
      preserve_split = true
      force_split = 2
    }

    windowrulev2 = workspace 3, class:^(${config.me.wm.browser})$
    windowrulev2 = workspace 4, class:^(spotify)$
    windowrulev2 = workspace 4, class:^(SimpMusic)$
    windowrulev2 = workspace 4, title:^(ncspot)$
    windowrulev2 = workspace 4, class:^(discord)$
    windowrulev2 = workspace 6, class:^(.gamescope-wrapped)$

    windowrulev2 = float, title:^(About)$
    windowrulev2 = float, title:^(Organizer)$
    windowrulev2 = float, title:^(Preferences)$
    windowrulev2 = float, title:^(Steam - Update News)$
    windowrulev2 = float, title:^(Friends List)$
    windowrulev2 = float, title:^(filechooser)$
    windowrulev2 = float, class:^(Pqiv)$
    windowrulev2 = float, class:^(1Password)$
    windowrulev2 = float, class:^(Org.gnome.NautilusPreviewer)$
    windowrulev2 = float, class:^(Main)$
    windowrulev2 = float, class:^(Matplotlib)$
    windowrulev2 = float, class:^(Ryujinx)$
    windowrulev2 = float, class:^(SimpMusic)$

    windowrulev2 = noscreenshare,class:^(Bitwarden)$
    windowrulev2 = suppressevent maximize, class:^(${config.me.wm.browser})$
    windowrulev2 = center, floating:1

    windowrulev2 = noblur, class:^(Gromit-mpx)$
    windowrulev2 = opacity 1 override, 1 override, class:^(Gromit-mpx)$
    windowrulev2 = noshadow, class:^(Gromit-mpx)$
    windowrulev2 = suppressevent fullscreen, class:^(Gromit-mpx)$
    windowrulev2 = size 100% 100%, class:^(Gromit-mpx)$

    workspace = w[t1], gapsout:0, gapsin:0
    workspace = w[tg1], gapsout:0, gapsin:0
    workspace = f[1], gapsout:0, gapsin:0
    workspace = special:gromit, gapsin:0, gapsout:0, on-created-empty:${getExe pkgs.gromit-mpx} -a

    windowrulev2 = bordersize 0, floating:0, onworkspace:w[t1]
    windowrulev2 = rounding 0, floating:0, onworkspace:w[t1]
    windowrulev2 = bordersize 0, floating:0, onworkspace:w[tg1]
    windowrulev2 = rounding 0, floating:0, onworkspace:w[tg1]
    windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
    windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

    bind = SUPER, t, exec, ${term} ${getExe pkgs.my.tmux-sessionizer} ~/
    bind = SUPER SHIFT, t, exec, ${term} -e tmux new-session
    bind = SUPER, s, exec, ${term} ${getExe pkgs.my.tmux-sshr}
    bind = SUPER SHIFT, s, exec, ${getExe pkgs.my.swap-theme}

    bind = SUPER, e, exec, ${term} ${getExe pkgs.lf}
    bind = SUPER SHIFT, e, exec, ${term} sudo ${getExe pkgs.lf}

    bind = SUPER, w, exec, ${browser}
    bind = SUPER, u, exec, ${getExe' pkgs._1password-gui "1password"} --quick-access
    bind = SUPER, d, exec, ${getExe pkgs.j4-dmenu-desktop} --no-generic -d '${getExe pkgs.bemenu} -p "DESKTOP"'

    bind = SUPER, m, exec, ${pkgs.writeShellScript "open-note" ''
      dir="$HOME/notes"
      note=$(ls $dir | sed 's/\.md$//' | bemenu -p "NOTE")
      [ -n "$note" ] && ${term} -e $EDITOR "$dir/$note.md"
    ''}

    bind = SUPER, n, exec, ${term} ${getExe pkgs.zsh} -c '${getExe' pkgs.networkmanager "nmcli"} device wifi rescan && unset COLORTERM && TERM=xterm-old ${getExe' pkgs.networkmanager "nmtui"}'
    bind = SUPER SHIFT, n, exec, ${getExe' pkgs.networkmanager "nmcli"} device wifi rescan

    bind = SUPER, b, exec, ${getExe pkgs.adw-bluetooth}
    bind = SUPER SHIFT, b, exec, ${pkgs.writeShellScript "bluetooth-toggle" ''
      airpods="D4:68:AA:88:8E:32"
      if ${getExe' pkgs.bluez "bluetoothctl"} info $airpods | grep -q "Connected: yes"; then
        echo -e "disconnect $airpods\nquit" | ${getExe' pkgs.bluez "bluetoothctl"}
      else
        echo -e "connect $airpods\nquit" | ${getExe' pkgs.bluez "bluetoothctl"}
      fi
    ''}

    bind = SUPER SHIFT, p, exec, ${getExe pkgs.copyq} show
    bind = SUPER SHIFT, i, exec, ${getExe' pkgs.procps "pkill"} -USR1 waybar

    bind = SUPER, o, togglespecialworkspace, gromit
    bind = , F9, togglespecialworkspace, gromit
    bind = SUPER SHIFT, o, exec, ${getExe pkgs.gromit-mpx} --clear
    bind = ALT SHIFT, o, exec, ${getExe pkgs.gromit-mpx} --undo

    bind = SUPER, p, exec, ${getExe pkgs.my.powermenu}
    bind = SUPER SHIFT, c, exec, ${getExe pkgs.my.color-picker}

    bind = SUPER, x, exec, ${getExe' pkgs.dunst "dunstctl"} close-all
    bind = SUPER, r, exec, ${getExe' pkgs.dunst "dunstctl"} history-pop
    bind = SUPER, a, exec, ${getExe' pkgs.dunst "dunstctl"} action

    bind = SUPER, q, killactive
    bind = SUPER, f, fullscreen, 0
    bind = SUPER, Return, togglefloating
    bind = SUPER, g, focuswindow, floating
    bind = SUPER, c, centerwindow

    bind = SUPER, h, movefocus, l
    bind = SUPER, j, movefocus, d
    bind = SUPER, k, movefocus, u
    bind = SUPER, l, movefocus, r

    bind = SUPER CTRL, h, movewindow, l
    bind = SUPER CTRL, j, movewindow, d
    bind = SUPER CTRL, k, movewindow, u
    bind = SUPER CTRL, l, movewindow, r

    bind = SUPER CTRL, BackSpace, movewindow, l
    bind = SUPER CTRL, Tab, movewindow, d
    bind = SUPER CTRL SHIFT, Tab, movewindow, u

    bind = SUPER SHIFT, h, resizeactive, -30 0
    bind = SUPER SHIFT, j, resizeactive, 0 30
    bind = SUPER SHIFT, k, resizeactive, 0 -30
    bind = SUPER SHIFT, l, resizeactive, 30 0

    bind = SUPER SHIFT, equal, workspace, 1
    bind = SUPER, bracketleft, workspace, 2
    bind = SUPER SHIFT, bracketleft, workspace, 3
    bind = SUPER SHIFT, 9, workspace, 4
    bind = SUPER SHIFT, 7, workspace, 5
    bind = SUPER, equal, workspace, 6
    bind = SUPER SHIFT, 0, workspace, 7
    bind = SUPER SHIFT, bracketright, workspace, 8
    bind = SUPER, bracketright, workspace, 9
    bind = SUPER SHIFT, 5, workspace, 10

    bind = SUPER, 1, movetoworkspace, 1
    bind = SUPER, 2, movetoworkspace, 2
    bind = SUPER, 3, movetoworkspace, 3
    bind = SUPER, 4, movetoworkspace, 4
    bind = SUPER, 5, movetoworkspace, 5
    bind = SUPER, 6, movetoworkspace, 6
    bind = SUPER, 7, movetoworkspace, 7
    bind = SUPER, 8, movetoworkspace, 8
    bind = SUPER, 9, movetoworkspace, 9
    bind = SUPER, 0, movetoworkspace, 10

    bindm = SUPER, mouse:272, movewindow
    bindm = SUPER, mouse:273, resizewindow

    bindl = , XF86AudioNext, exec, ${getExe pkgs.playerctl} next
    bindl = , XF86AudioPrev, exec, ${getExe pkgs.playerctl} previous
    bindl = , XF86AudioPlay, exec, ${getExe pkgs.playerctl} play-pause
    bindel = , XF86AudioRaiseVolume, exec, ${getExe pkgs.my.change-volume} up
    bindel = , XF86AudioLowerVolume, exec, ${getExe pkgs.my.change-volume} down
    bindel = , XF86AudioMute, exec, ${getExe pkgs.my.change-volume} mute
    bindel = , XF86MonBrightnessUp, exec, ${getExe pkgs.my.change-brightness} up
    bindel = , XF86MonBrightnessDown, exec, ${getExe pkgs.my.change-brightness} down

    bindn = , Print, exec, ${getExe pkgs.my.screenshot} region
    bindn = ALT, Sys_Req, exec, ${getExe pkgs.my.screenshot} window
    bindn = SHIFT, Print, exec, ${getExe pkgs.my.screenshot} monitor

    exec-once = ${getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd --all
    exec-once = ${getExe' pkgs.kdePackages.kdeconnect-kde "kdeconnect-indicator"}
    exec-once = ${getExe' pkgs.hyprland "hyprctl"} dispatch workspace 1

    exec = ${pkgs.writeShellScript "set-wallpaper" ''
      if ! pgrep -x hyprpaper > /dev/null; then
        ${getExe pkgs.hyprpaper} &
        sleep 1
      fi

      WALL_DIR="$HOME/pictures/wallpapers"

      if [ -f "$TINTED_FILE" ]; then
          TARGET="$WALL_DIR/$(< "$TINTED_FILE")"
      else
          TARGET="$WALL_DIR/black-and-white-landscapes"
      fi

      if [ -d "$TARGET" ]; then
        wallpaper=$(shuf -e -n1 --random-source=<(date +%Y%m%d | md5sum) "$TARGET"/*)
        ${getExe' pkgs.hyprland "hyprctl"} hyprpaper preload "$wallpaper"
        ${getExe' pkgs.hyprland "hyprctl"} hyprpaper wallpaper ",$wallpaper"
      fi
    ''}
  '';

  hj.xdg.config.files."hypr/hyprpaper.conf".text = ''
    ipc = true
  '';
}
