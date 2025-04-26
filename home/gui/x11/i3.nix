{
  myLib,
  pkgs,
  lib,
  config,
  ...
}:

let
  palette = myLib.palette;
in
lib.mkIf config.me.gui.enable {
  xsession.windowManager.i3 = {
    enable = true;

    extraConfig = ''
      set $tmux ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux new-session
      set $term ${pkgs.alacritty}/bin/alacritty -e
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
            "${modifier}+t" =
              "exec --no-startup-id $term ${pkgs.scripts.tmux-sessionizer}/bin/tmux-sessionizer ~/";
            "${modifier}+s" = "exec --no-startup-id $term ${pkgs.scripts.tmux-sshr}/bin/tmux-sshr";
            "${modifier}+Shift+t" = "exec --no-startup-id $tmux";
            "${modifier}+q" = "kill";
            "${modifier}+e" = "exec --no-startup-id $term ${pkgs.lf}/bin/lf";
            "${modifier}+Shift+e" = "exec --no-startup-id $term sudo ${pkgs.lf}/bin/lf";
            "${modifier}+n" =
              "exec --no-startup-id $term ${pkgs.zsh}/bin/zsh -c '${pkgs.networkmanager}/bin/nmcli device wifi rescan && unset COLORTERM && TERM=xterm-old ${pkgs.networkmanager}/bin/nmtui'";
            "${modifier}+b" = "exec --no-startup-id $term ${pkgs.bluetuith}/bin/bluetuith --no-warning";
            "${modifier}+Shift+b" = "exec --no-startup-id ${pkgs.writeShellScript "bluetooth-toogle" ''
              if ${pkgs.bluez}/bin/bluetoothctl info ${airpods} | grep -q "Connected: yes"; then
                echo -e "disconnect ${airpods}\nquit" | ${pkgs.bluez}/bin/bluetoothctl
              else
                echo -e "connect ${airpods}\nquit" | ${pkgs.bluez}/bin/bluetoothctl
              fi
            ''}";
            "${modifier}+Shift+n" = "exec --no-startup-id ${pkgs.networkmanager}/bin/nmcli device wifi rescan";

            "${modifier}+w" = "exec --no-startup-id $browser";
            "${modifier}+Shift+p" = "exec --no-startup-id ${pkgs.copyq}/bin/copyq show";
            # "${modifier}+s" = "exec --no-startup-id ${pkgs.scripts.dofus-travel}/bin/dofus-travel";

            "${modifier}+u" = "exec --no-startup-id ${pkgs._1password-gui}/bin/1password --quick-access";

            "${modifier}+d" =
              "exec --no-startup-id ${j4-dmenu-desktop}/bin/j4-dmenu-desktop --no-generic -d '${pkgs.bemenu}/bin/bemenu -p \"DESKTOP\"'";
            "${modifier}+i" = "exec --no-startup-id ${pkgs.polybar}/bin/polybar-msg cmd toggle";
            "${modifier}+space" = "exec --no-startup-id ${pkgs.dunst}/bin/dunstctl close-all";
            "${modifier}+r" = "exec --no-startup-id ${pkgs.dunst}/bin/dunstctl history-pop";
            "${modifier}+a" = "exec --no-startup-id ${pkgs.dunst}/bin/dunstctl action";

            "${modifier}+o" = "exec --no-startup-id ${pkgs.gromit-mpx}/bin/gromit-mpx --toggle";
            "F9" = "exec --no-startup-id ${pkgs.gromit-mpx}/bin/gromit-mpx --toggle";

            "${modifier}+Shift+o" = "exec --no-startup-id ${pkgs.gromit-mpx}/bin/gromit-mpx --clear";

            "${modifier}+p" = "exec --no-startup-id ${pkgs.scripts.powermenu}/bin/powermenu";
            "--release ${modifier}+Shift+c" = "exec ${pkgs.scripts.color-picker}/bin/color-picker";
            "--release ${modifier}+Shift+m" =
              "exec $tmux -s 'xprop' '${pkgs.xorg.xprop}/bin/xprop; exec $SHELL";

            "Print" = "exec --no-startup-id ${pkgs.scripts.screenshot}/bin/screenshot region";
            "$alt+Sys_Req" = "exec --no-startup-id ${pkgs.scripts.screenshot}/bin/screenshot window";
            "Shift+Print" = "exec --no-startup-id ${pkgs.scripts.screenshot}/bin/screenshot monitor";

            "XF86AudioRaiseVolume" = "exec --no-startup-id ${pkgs.scripts.change-volume}/bin/change-volume up";
            "XF86AudioLowerVolume" =
              "exec --no-startup-id ${pkgs.scripts.change-volume}/bin/change-volume down";
            "XF86AudioMute" = "exec --no-startup-id ${pkgs.scripts.change-volume}/bin/change-volume mute";

            "XF86AudioNext" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl next";
            "XF86AudioPrev" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl previous";
            "XF86AudioPlay" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl play-pause";

            "${modifier}+Shift+r" = "restart";

            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";

            "${modifier}+Ctrl+h" = "move left $window-move-amount";
            "${modifier}+Ctrl+j" = "move down $window-move-amount";
            "${modifier}+Ctrl+k" = "move up $window-move-amount";
            "${modifier}+Ctrl+l" = "move right $window-move-amount";

            "${modifier}+c" = "move position center";

            "${modifier}+f" = "fullscreen toggle";
            "${modifier}+Return" = "floating toggle";
            "${modifier}+g" = "focus mode_toggle";

            "${modifier}+plus" = "workspace $ws1";
            "${modifier}+bracketleft" = "workspace $ws2";
            "${modifier}+braceleft" = "workspace $ws3";
            "${modifier}+parenleft" = "workspace $ws4";
            "${modifier}+ampersand" = "workspace $ws5";
            "${modifier}+equal" = "workspace $ws6";
            "${modifier}+parenright" = "workspace $ws7";
            "${modifier}+braceright" = "workspace $ws8";
            "${modifier}+bracketright" = "workspace $ws9";
            "${modifier}+percent" = "workspace $ws10";

            "${modifier}+Shift+plus" = "move container to workspace $ws1";
            "${modifier}+Shift+bracketleft" = "move container to workspace $ws2";
            "${modifier}+Shift+braceleft" = "move container to workspace $ws3";
            "${modifier}+Shift+parenleft" = "move container to workspace $ws4";
            "${modifier}+Shift+ampersand" = "move container to workspace $ws5";
            "${modifier}+Shift+equal" = "move container to workspace $ws6";
            "${modifier}+Shift+bracketright" = "move container to workspace $ws7";
            "${modifier}+Shift+braceright" = "move container to workspace $ws8";
            "${modifier}+Shift+parenright" = "move container to workspace $ws9";
            "${modifier}+Shift+percent" = "move container to workspace $ws10";

            "${modifier}+Shift+h" = "resize shrink width 10 px or 10 ppt";
            "${modifier}+Shift+j" = "resize grow height 10 px or 10 ppt";
            "${modifier}+Shift+k" = "resize shrink height 10 px or 10 ppt";
            "${modifier}+Shift+l" = "resize grow width 10 px or 10 ppt";

            "XF86MonBrightnessDown" =
              "exec --no-startup-id ${pkgs.scripts.change-brightness}/bin/change-brightness down";
            "XF86MonBrightnessUp" =
              "exec --no-startup-id ${pkgs.scripts.change-brightness}/bin/change-brightness up";
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
            { class = "feh"; }
            { class = "1Password"; }
            { class = "Org.gnome.NautilusPreviewer"; }
            { class = "Main"; }
            { class = "Matplotlib"; }
            { class = "gnome-calculator"; }
          ];
        };
        startup = [
          {
            command = "${pkgs.dbus}/bin/dbus-update-activation-environment --all";
            notification = false;
          }
          {
            command = "${pkgs.feh}/bin/feh --no-fehbg --bg-fill ${config.me.flakeDir}/assets/wallpaper.png";
            always = true;
            notification = false;
          }
          {
            command = "${pkgs.i3altlayout}/bin/i3altlayout";
            always = true;
            notification = false;
          }
          {
            command = "${pkgs.polybar}/bin/polybar-msg cmd restart";
            always = true;
            notification = false;
          }
          {
            command = "${pkgs.polybar}/bin/polybar";
            notification = false;
          }
          # hide polybar at startup
          # {
          #   command = "(xdo id -m -N Polybar && polybar-msg cmd hide)&";
          #   notification = false;
          # }

          {
            command = "${pkgs.i3}/bin/i3-msg workspace 1";
            notification = false;
          }
        ];
        terminal = "${pkgs.alacritty}/bin/alacritty";
        assigns = {
          "4" = [
            { class = "^spotify$"; }
            { title = "^ncspot$"; }
          ];
        };
        colors = rec {
          focused = rec {
            background = palette.bg0;
            border = palette.fg2;
            text = border;
            indicator = border;
            childBorder = border;
          };
          unfocused = rec {
            background = focused.border;
            border = palette.bg1;
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
            {
              command = "border pixel 0";
              criteria = {
                window_type = "Popup";
              };
            }
          ];
        };
      };
  };
}
