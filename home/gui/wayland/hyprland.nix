{
  myLib,
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (myLib) hex;
  rgba = color: alpha: "rgba(${color}${alpha})";

  tmux = "${lib.getExe pkgs.foot} -e ${lib.getExe pkgs.tmux} new-session";
  term = "${lib.getExe pkgs.foot} -e";
  browser = config.me.browser;

  airpods = "D4:68:AA:88:8E:32";
  j4-dmenu-desktop = pkgs.j4-dmenu-desktop.override {
    dmenu = pkgs.bemenu;
  };
in
lib.mkIf (config.me.gui.displayServer == "wayland") {
  xdg.configFile."zsh/.zshrc".text =
    lib.mkBefore # bash
      ''
        [[ $(tty) == "/dev/tty1" ]] && {
            source ~/.profile
            exec hyprland &> /dev/null
        }
      '';

  wayland.windowManager.hyprland = {
    enable = true;

    systemd = {
      enable = true;
      variables = [
        "DISPLAY"
        "HYPRLAND_INSTANCE_SIGNATURE"
        "WAYLAND_DISPLAY"
        "XDG_CURRENT_DESKTOP"
      ];
    };

    settings = {
      monitor = [
        ", preferred, auto, 1"
      ];

      workspace = [
        "w[t1], gapsout:0, gapsin:0"
        "w[tg1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"
        "special:gromit, gapsin:0, gapsout:0, on-created-empty: ${lib.getExe pkgs.gromit-mpx} -a"
      ];

      general = {
        gaps_in = 0;
        gaps_out = 0;
        "col.active_border" = rgba hex.fg2 "ee";
        "col.inactive_border" = rgba hex.bg1 "aa";
        layout = "dwindle";
        no_focus_fallback = true;
      };

      input = {
        kb_options = "compose:ralt";

        follow_mouse = 2;
        float_switch_override_focus = 0;

        repeat_rate = 30;
        repeat_delay = 200;

        touchpad = {
          natural_scroll = true;
        };
      };

      decoration = {
        rounding = 0;
        blur = {
          enabled = false;
        };
        shadow = {
          enabled = false;
        };
      };

      animations.enabled = false;

      dwindle = {
        preserve_split = true;
        force_split = 2;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        focus_on_activate = true;
        new_window_takes_over_fullscreen = 2;
        middle_click_paste = false;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
      };

      cursor = {
        hide_on_key_press = true;
      };

      binds = {
        movefocus_cycles_fullscreen = false;
      };

      ecosystem.no_update_news = true;

      windowrulev2 = [
        "float,title:^(About)$"
        "float,title:^(Organizer)$"
        "float,title:^(Preferences)$"
        "float,title:^(Steam - Update News)$"
        "float,title:^(Friends List)$"
        "float,title:^(filechooser)$"
        "float,class:^(feh)$"
        "float,class:^(Pqiv)$"
        "float,class:^(1Password)$"
        "float,class:^(Org.gnome.NautilusPreviewer)$"
        "float,class:^(Main)$"
        "float,class:^(Matplotlib)$"
        "float,class:^(gnome-calculator)$"
        "float,class:^(Ryujinx)$"

        "noscreenshare,class:^(Bitwarden)$"

        "workspace 4,class:^(spotify)$"
        "workspace 4,title:^(ncspot)$"

        "center,floating:1"

        "bordersize 0, floating:0, onworkspace:w[t1]"
        "rounding 0, floating:0, onworkspace:w[t1]"
        "bordersize 0, floating:0, onworkspace:w[tg1]"
        "rounding 0, floating:0, onworkspace:w[tg1]"
        "bordersize 0, floating:0, onworkspace:f[1]"
        "rounding 0, floating:0, onworkspace:f[1]"

        "noblur, class:^(Gromit-mpx)$"
        "opacity 1 override, 1 override, class:^(Gromit-mpx)$"
        "noshadow, class:^(Gromit-mpx)$"
        "suppressevent fullscreen, class:^(Gromit-mpx)$"
        "size 100% 100%, class:^(Gromit-mpx)$"
      ];

      bind = [
        "SUPER,t,exec,${term} ${lib.getExe pkgs.scripts.tmux-sessionizer} ~/"
        "SUPER,s,exec,${term} ${lib.getExe pkgs.scripts.tmux-sshr}"
        "SUPERSHIFT,t,exec,${tmux}"
        "SUPER,e,exec,${term} ${lib.getExe pkgs.lf}"
        "SUPERSHIFT,e,exec,${term} sudo ${lib.getExe pkgs.lf}"
        "SUPER,w,exec,${browser}"

        "SUPER,u,exec,${lib.getExe' pkgs._1password-gui "1password"} --quick-access"
        # "CTRL SHIFT,L,pass,class:^(1Password)$"

        "SUPER,d,exec,${lib.getExe j4-dmenu-desktop} --no-generic -d '${lib.getExe pkgs.bemenu} -p \"DESKTOP\"'"

        "SUPER,m,exec,${pkgs.writeShellScript "open-note" ''
          dir="$HOME/notes"
          note=$(ls $dir | sed 's/\.md$//' | bemenu -p "NOTE")
          [ -n "$note" ] && ${term} $EDITOR "$dir/$note.md"
        ''}"

        "SUPER,n,exec,${term} ${lib.getExe pkgs.zsh} -c '${lib.getExe' pkgs.networkmanager "nmcli"} device wifi rescan && unset COLORTERM && TERM=xterm-old ${lib.getExe' pkgs.networkmanager "nmtui"}"
        "SUPERSHIFT,n,exec,${lib.getExe' pkgs.networkmanager "nmcli"} device wifi rescan"
        "SUPER,b,exec,${term} ${lib.getExe pkgs.bluetuith} --no-warning"
        "SUPERSHIFT,b,exec,${pkgs.writeShellScript "bluetooth-toggle" ''
          if ${lib.getExe' pkgs.bluez "bluetoothctl"} info ${airpods} | grep -q "Connected: yes"; then
            echo -e "disconnect ${airpods}\nquit" | ${lib.getExe' pkgs.bluez "bluetoothctl"}
          else
            echo -e "connect ${airpods}\nquit" | ${lib.getExe' pkgs.bluez "bluetoothctl"}
          fi
        ''}"

        "SUPERSHIFT,p,exec,${lib.getExe pkgs.copyq} show"
        "SUPER,o,togglespecialworkspace,gromit"
        ",F9,exec,togglespecialworkspace,gromit"
        "SUPERSHIFT,o,exec,${lib.getExe pkgs.gromit-mpx} --clear"
        "ALTSHIFT,o, exec,${lib.getExe pkgs.gromit-mpx} --undo"
        "SUPER,p,exec,${lib.getExe pkgs.scripts.powermenu}"

        "SUPER,x,exec,${lib.getExe' pkgs.dunst "dunstctl"} close-all"
        "SUPER,r,exec,${lib.getExe' pkgs.dunst "dunstctl"} history-pop"
        "SUPER,a,exec,${lib.getExe' pkgs.dunst "dunstctl"} action"

        "SUPER,q,killactive"
        "SUPER,f,fullscreen,0"
        "SUPER,Return,togglefloating"
        "SUPER,g,focuswindow,floating"
        "SUPER,c,centerwindow"

        "SUPER,h,movefocus,l"
        "SUPER,j,movefocus,d"
        "SUPER,k,movefocus,u"
        "SUPER,l,movefocus,r"

        "SUPERCTRL,h,movewindow,l"
        "SUPERCTRL,j,movewindow,d"
        "SUPERCTRL,k,movewindow,u"
        "SUPERCTRL,l,movewindow,r"
        "SUPERCTRL,BackSpace,movewindow,l"
        "SUPERCTRL,Tab,movewindow,d"
        "SUPERCTRLSHIFT,Tab,movewindow,u"

        "SUPERSHIFT,h,resizeactive,-30 0"
        "SUPERSHIFT,j,resizeactive,0 30"
        "SUPERSHIFT,k,resizeactive,0 -30"
        "SUPERSHIFT,l,resizeactive,30 0"

        "SUPERSHIFT,equal,workspace,1"
        "SUPER,bracketleft,workspace,2"
        "SUPERSHIFT,bracketleft,workspace,3"
        "SUPERSHIFT,9,workspace,4"
        "SUPERSHIFT,7,workspace,5"
        "SUPER,equal,workspace,6"
        "SUPERSHIFT,0,workspace,7"
        "SUPERSHIFT,bracketright,workspace,8"
        "SUPER,bracketright,workspace,9"
        "SUPERSHIFT,5,workspace,10"

        "SUPER,1,movetoworkspace,1"
        "SUPER,2,movetoworkspace,2"
        "SUPER,3,movetoworkspace,3"
        "SUPER,4,movetoworkspace,4"
        "SUPER,5,movetoworkspace,5"
        "SUPER,6,movetoworkspace,6"
        "SUPER,7,movetoworkspace,7"
        "SUPER,8,movetoworkspace,8"
        "SUPER,9,movetoworkspace,9"
        "SUPER,0,movetoworkspace,10"
      ];

      bindl = [
        ",XF86AudioNext,exec,${lib.getExe pkgs.playerctl} next"
        ",XF86AudioPrev,exec,${lib.getExe pkgs.playerctl} previous"
        ",XF86AudioPlay,exec,${lib.getExe pkgs.playerctl} play-pause"
      ];

      bindel = [
        ",XF86AudioRaiseVolume,exec,${lib.getExe pkgs.scripts.change-volume} up"
        ",XF86AudioLowerVolume,exec,${lib.getExe pkgs.scripts.change-volume} down"
        ",XF86AudioMute,exec,${lib.getExe pkgs.scripts.change-volume} mute"
        ",XF86MonBrightnessUp,exec,${lib.getExe pkgs.scripts.change-brightness} up"
        ",XF86MonBrightnessDown,exec,${lib.getExe pkgs.scripts.change-brightness} down"
      ];

      bindn = [
        ",Print,exec,${lib.getExe pkgs.scripts.screenshot} region"
        "ALT,Sys_Req,exec,${lib.getExe pkgs.scripts.screenshot} window"
        "SHIFT,Print,exec,${lib.getExe pkgs.scripts.screenshot} monitor"
        "SUPERSHIFT,c,exec,${lib.getExe pkgs.scripts.color-picker}"
      ];

      bindm = [
        "SUPER,mouse:272,movewindow"
        "SUPER,mouse:273,resizewindow"
      ];

      exec = [
        "${pkgs.writeShellScript "set-wallpaper" # bash
          ''
            if ! pgrep -x hyprpaper > /dev/null; then
              "${lib.getExe pkgs.hyprpaper}" &
            fi

            socket="/run/user/$UID/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.hyprpaper.sock"
            timeout=30
            while [[ ! -S "$socket" ]] && ((timeout > 0)); do
              sleep 0.1
              ((timeout--))
            done

            # if [[ -d ~/pictures/wallpapers/landscapes ]]; then
            if [[ false ]]; then
              wallpaper=$(shuf -e -n1 --random-source=<(date +%Y%m%d | md5sum) \
                ~/pictures/wallpapers/landscapes/*)

              ${lib.getExe' pkgs.hyprland "hyprctl"} hyprpaper preload $wallpaper
              ${lib.getExe' pkgs.hyprland "hyprctl"} hyprpaper wallpaper ",$wallpaper"
            else
              ${lib.getExe' pkgs.hyprland "hyprctl"} hyprpaper preload ${config.me.flakeDir}/assets/wallpaper.jpg
              ${lib.getExe' pkgs.hyprland "hyprctl"} hyprpaper wallpaper ",${config.me.flakeDir}/assets/wallpaper.jpg"
            fi
          ''
        }"
      ];

      exec-once = [
        "${lib.getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd --all"
        "kdeconnect-cli --refresh"
        "${lib.getExe' pkgs.hyprland "hyprctl"} dispatch workspace 1"
      ];
    };
  };

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    ipc = true
  '';
}
