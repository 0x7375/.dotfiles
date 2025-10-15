{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (config.me) gui;
in
lib.mkIf (gui.displayServer == "xorg") {
  xsession.windowManager.i3 = {
    enable = true;

    extraConfig = ''
      set $tmux ${lib.getExe pkgs.${gui.terminal}} -e ${lib.getExe pkgs.tmux} new-session
      set $term ${lib.getExe pkgs.${gui.terminal}} -e
      set $browser ${config.me.browser}
      set $alt Mod1
      set $win Mod4

      set $window-move-amount 40px

      set $ws1 "1"
      set $ws2 "2"
      set $ws3 "3"
      set $ws4 "4"
      set $ws5 "5"
      set $ws6 "6"
      set $ws7 "7"
      set $ws8 "8"
      set $ws9 "9"
      set $ws10 "10"

      set_from_resource $focused_bg bg0 #000000
      set_from_resource $focused_fg fg2 #000000
      set_from_resource $unfocused_bg bg1 #000000
    '';
    config =
      let
        modifier = "Mod4";
        titlebar = false;
        border = 1;
      in
      {
        bars = [ ];
        inherit modifier;
        focus = {
          wrapping = "no";
          newWindow = "focus";
        };
        keybindings =
          let
            airpods = "D4:68:AA:88:8E:32";

            j4-dmenu-desktop = pkgs.j4-dmenu-desktop.override {
              dmenu = pkgs.bemenu;
            };
          in
          {
            "${modifier}+t" = "exec --no-startup-id $term ${lib.getExe pkgs.scripts.tmux-sessionizer} ~/";
            "${modifier}+s" = "exec --no-startup-id $term ${lib.getExe pkgs.scripts.tmux-sshr}";
            "${modifier}+Shift+s" = "exec --no-startup-id ${lib.getExe pkgs.scripts.swap-theme}";
            "${modifier}+Shift+t" = "exec --no-startup-id $tmux";
            "${modifier}+q" = "kill";
            "${modifier}+e" = "exec --no-startup-id $term ${lib.getExe' pkgs.lf "lf"}";
            "${modifier}+Shift+e" = "exec --no-startup-id $term sudo ${lib.getExe' pkgs.lf "lf"}";
            "${modifier}+m" =
              let
                dir = "$HOME/notes";
              in
              "exec --no-startup-id $term $(${pkgs.writeShellScript "open-note" ''
                note=$(ls ${dir} | sed 's/\.md$//' | bemenu -p "NOTE")
                [ -n "$note" ] && echo $EDITOR "${dir}/$note.md"
              ''})";
            "${modifier}+n" =
              "exec --no-startup-id $term ${lib.getExe pkgs.zsh} -c '${lib.getExe' pkgs.networkmanager "nmcli"} device wifi rescan && unset COLORTERM && TERM=xterm-old ${lib.getExe' pkgs.networkmanager "nmtui'"}";
            "${modifier}+b" = "exec --no-startup-id $term ${lib.getExe pkgs.bluetuith} --no-warning";
            "${modifier}+Shift+b" = "exec --no-startup-id ${pkgs.writeShellScript "bluetooth-toogle" ''
              if ${lib.getExe' pkgs.bluez "bluetoothctl"} info ${airpods} | grep -q "Connected: yes"; then
                echo -e "disconnect ${airpods}\nquit" | ${lib.getExe' pkgs.bluez "bluetoothctl"}
              else
                echo -e "connect ${airpods}\nquit" | ${lib.getExe' pkgs.bluez "bluetoothctl"}
              fi
            ''}";
            "${modifier}+Shift+n" =
              "exec --no-startup-id ${lib.getExe' pkgs.networkmanager "nmcli"} device wifi rescan";

            "${modifier}+w" = "exec --no-startup-id $browser";
            "${modifier}+Shift+p" = "exec --no-startup-id ${lib.getExe pkgs.copyq} show";
            # "${modifier}+s" = "exec --no-startup-id ${lib.getExe pkgs.scripts.dofus-travel}";

            "${modifier}+u" =
              "exec --no-startup-id ${lib.getExe' pkgs._1password-gui "1password"} --quick-access";

            "${modifier}+d" =
              "exec --no-startup-id ${lib.getExe j4-dmenu-desktop} --no-generic -d '${lib.getExe pkgs.bemenu} -p \"DESKTOP\"'";
            "${modifier}+i" = "exec --no-startup-id ${lib.getExe' pkgs.polybar "polybar-msg"} cmd toggle";
            "${modifier}+x" = "exec --no-startup-id ${lib.getExe' pkgs.dunst "dunstctl"} close-all";
            "${modifier}+r" = "exec --no-startup-id ${lib.getExe' pkgs.dunst "dunstctl"} history-pop";
            "${modifier}+a" = "exec --no-startup-id ${lib.getExe' pkgs.dunst "dunstctl"} action";

            "${modifier}+o" = "exec --no-startup-id ${lib.getExe pkgs.gromit-mpx} --toggle";
            "F9" = "exec --no-startup-id ${lib.getExe pkgs.gromit-mpx} --toggle";

            "${modifier}+Shift+o" = "exec --no-startup-id ${lib.getExe pkgs.gromit-mpx} --clear";

            "${modifier}+p" = "exec --no-startup-id ${lib.getExe pkgs.scripts.powermenu}";
            "--release ${modifier}+Shift+c" = "exec ${lib.getExe pkgs.scripts.color-picker}";
            "--release ${modifier}+Shift+m" =
              "exec $tmux -s 'xprop' '${lib.getExe' pkgs.xorg.xprop "xprop"} exec $SHELL";

            "Print" = "exec --no-startup-id ${lib.getExe pkgs.scripts.screenshot} region";
            "$alt+Sys_Req" = "exec --no-startup-id ${lib.getExe pkgs.scripts.screenshot} window";
            "Shift+Print" = "exec --no-startup-id ${lib.getExe pkgs.scripts.screenshot} monitor";

            "XF86AudioRaiseVolume" = "exec --no-startup-id ${lib.getExe pkgs.scripts.change-volume} up";
            "XF86AudioLowerVolume" = "exec --no-startup-id ${lib.getExe pkgs.scripts.change-volume} down";
            "XF86AudioMute" = "exec --no-startup-id ${lib.getExe pkgs.scripts.change-volume} mute";

            "XF86AudioNext" = "exec --no-startup-id ${lib.getExe pkgs.playerctl} next";
            "XF86AudioPrev" = "exec --no-startup-id ${lib.getExe pkgs.playerctl} previous";
            "XF86AudioPlay" = "exec --no-startup-id ${lib.getExe pkgs.playerctl} play-pause";

            "${modifier}+Shift+r" = "restart";

            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";

            # duplicate remaps for apps I remap using keyd-application-mapper
            "${modifier}+Ctrl+h" = "move left $window-move-amount";
            "${modifier}+BackSpace" = "move left $window-move-amount";

            "${modifier}+Ctrl+j" = "move down $window-move-amount";
            "${modifier}+Ctrl+Tab" = "move down $window-move-amount";

            "${modifier}+Ctrl+k" = "move up $window-move-amount";
            "${modifier}+Ctrl+Shift+Tab" = "move up $window-move-amount";

            "${modifier}+Ctrl+l" = "move right $window-move-amount";

            "${modifier}+c" = "move position center";

            "${modifier}+f" = "fullscreen toggle";
            "${modifier}+Return" = "floating toggle";
            "${modifier}+g" = "focus mode_toggle";

            "${modifier}+Shift+equal" = "workspace $ws1";
            "${modifier}+bracketleft" = "workspace $ws2";
            "${modifier}+Shift+bracketleft" = "workspace $ws3";
            "${modifier}+Shift+9" = "workspace $ws4";
            "${modifier}+Shift+7" = "workspace $ws5";
            "${modifier}+equal" = "workspace $ws6";
            "${modifier}+Shift+0" = "workspace $ws7";
            "${modifier}+Shift+bracketright" = "workspace $ws8";
            "${modifier}+bracketright" = "workspace $ws9";
            "${modifier}+Shift+5" = "workspace $ws10";

            "${modifier}+1" = "move container to workspace $ws1";
            "${modifier}+2" = "move container to workspace $ws2";
            "${modifier}+3" = "move container to workspace $ws3";
            "${modifier}+4" = "move container to workspace $ws4";
            "${modifier}+5" = "move container to workspace $ws5";
            "${modifier}+6" = "move container to workspace $ws6";
            "${modifier}+7" = "move container to workspace $ws7";
            "${modifier}+8" = "move container to workspace $ws8";
            "${modifier}+9" = "move container to workspace $ws9";
            "${modifier}+0" = "move container to workspace $ws10";

            "${modifier}+Shift+h" = "resize shrink width 30 px or 30 ppt";
            "${modifier}+Shift+j" = "resize grow height 30 px or 30 ppt";
            "${modifier}+Shift+k" = "resize shrink height 30 px or 30 ppt";
            "${modifier}+Shift+l" = "resize grow width 30 px or 30 ppt";

            "XF86MonBrightnessDown" = "exec --no-startup-id ${lib.getExe pkgs.scripts.change-brightness} down";
            "XF86MonBrightnessUp" = "exec --no-startup-id ${lib.getExe pkgs.scripts.change-brightness} up";
          };
        floating = {
          inherit modifier;
          inherit border;
          inherit titlebar;
          criteria = [
            { window_role = "About"; }
            { window_role = "Organizer"; }
            { window_role = "Preferences"; }
            { window_role = "bubble"; }
            { window_role = "page-info"; }
            { window_role = "pop-up"; }
            { window_role = "task_dialog"; }
            { window_role = "toolbox"; }
            { window_role = "webconsole"; }
            { window_type = "dialog"; }
            { window_type = "menu"; }
            { title = "Steam - Update News"; }
            { title = "^Friends List$"; }
            { title = "^filechooser$"; }
            { class = "Pqiv"; }
            { class = "1Password"; }
            { class = "Org.gnome.NautilusPreviewer"; }
            { class = "Main"; }
            { class = "Matplotlib"; }
            { class = "gnome-calculator"; }
            { class = "Ryujinx"; }
          ];
        };
        startup = [
          {
            command = "${lib.getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd --all";
            notification = false;
          }
          {
            command = "kdeconnect-cli --refresh";
            notification = false;
          }
          {
            command = "xrdb -load ~/.config/X11/xresources";
            always = true;
            notification = false;
          }
          {
            command = "${pkgs.writeShellScript "set-wallpaper" ''
              wallpapers="$HOME/pictures/wallpapers/$(< ~/.local/state/current_theme)"
              if [[ -d $wallpapers ]]; then
                shuf -e -n1 --random-source=<(date +%Y%m%d | md5sum) \
                  ''${wallpapers}/* | \
                  ${lib.getExe' pkgs.findutils "xargs"} ${lib.getExe pkgs.feh} --no-fehbg --bg-fill
              else
                ${lib.getExe pkgs.feh} --no-fehbg --bg-fill ${config.me.flakeDir}/assets/wallpaper.jpg
              fi
            ''}";
            always = true;
            notification = false;
          }
          {
            command = "${lib.getExe' pkgs.i3altlayout "i3altlayout"}";
            always = true;
            notification = false;
          }
          {
            command = "${lib.getExe' pkgs.polybar "polybar-msg"} cmd restart";
            always = true;
            notification = false;
          }
          {
            command = "${lib.getExe' pkgs.polybar "polybar"}";
            notification = false;
          }
          # hide polybar at startup
          # {
          #   command = "(xdo id -m -N Polybar && polybar-msg cmd hide)&";
          #   notification = false;
          # }

          {
            command = "${lib.getExe' pkgs.i3 "i3-msg"} workspace 1";
            notification = false;
          }
        ];
        terminal = "${lib.getExe' pkgs.${gui.terminal} gui.term}";
        assigns = {
          "4" = [
            { class = "^spotify$"; }
            { title = "^ncspot$"; }
          ];
        };
        colors = rec {
          focused = rec {
            background = "$focused_bg";
            border = "$focused_fg";
            text = border;
            indicator = border;
            childBorder = border;
          };
          unfocused = rec {
            background = focused.border;
            border = "$unfocused_bg";
            text = border;
            indicator = border;
            childBorder = border;
          };
          focusedInactive = unfocused;
          placeholder = unfocused;
          urgent = unfocused;
        };
        window = {
          hideEdgeBorders = "smart";
          inherit titlebar;
          inherit border;
          commands = [
            {
              command = "border pixel ${toString border}";
              criteria = {
                class = ".*";
              };
            }
            {
              command = "move position center";
              criteria = {
                floating = true;
              };
            }
            {
              command = "border pixel 0";
              criteria = {
                window_role = "Popup";
              };
            }
          ];
        };
      };
  };
}
