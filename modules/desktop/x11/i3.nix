{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (config.me) desktop;
  inherit (lib) getExe getExe';
in
lib.mkIf (desktop.displayServer == "xorg") {
  hj.xdg.config.files."i3/config".text =
    let
      airpods = "D4:68:AA:88:8E:32";
      j4-dmenu-desktop = pkgs.j4-dmenu-desktop.override {
        dmenu = pkgs.bemenu;
      };
      dir = "$HOME/notes";
    in
    ''
      set $tmux ${getExe pkgs.${desktop.terminal}} -e ${getExe pkgs.tmux} new-session
      set $term ${getExe pkgs.${desktop.terminal}} -e
      set $browser ${config.me.browser}
      set $exec exec --no-startup-id
      set $exec_always exec_always --no-startup-id

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

      font pango:monospace 8.000000
      floating_modifier $win
      default_border pixel 1
      default_floating_border pixel 1
      hide_edge_borders smart
      focus_wrapping no
      focus_follows_mouse yes
      focus_on_window_activation focus
      mouse_warping output
      workspace_layout default
      workspace_auto_back_and_forth no

      client.focused $focused_fg $focused_bg $focused_fg $focused_fg $focused_fg
      client.focused_inactive $unfocused_bg $focused_fg $unfocused_bg $unfocused_bg $unfocused_bg
      client.unfocused $unfocused_bg $focused_fg $unfocused_bg $unfocused_bg $unfocused_bg
      client.urgent $unfocused_bg $focused_fg $unfocused_bg $unfocused_bg $unfocused_bg
      client.placeholder $unfocused_bg $focused_fg $unfocused_bg $unfocused_bg $unfocused_bg
      client.background #ffffff

      bindsym $win+t $exec $term ${getExe pkgs.scripts.tmux-sessionizer} ~/
      bindsym $win+s $exec $term ${getExe pkgs.scripts.tmux-sshr}
      bindsym $win+Shift+s $exec ${getExe pkgs.scripts.swap-theme}
      bindsym $win+Shift+t $exec $tmux
      bindsym $win+e $exec $term ${getExe pkgs.lf}
      bindsym $win+Shift+e $exec $term sudo ${getExe pkgs.lf}
      bindsym $win+m $exec $term $(${pkgs.writeShellScript "open-note" ''
        note=$(ls ${dir} | sed 's/\.md$//' | bemenu -p "NOTE")
        [ -n "$note" ] && echo $EDITOR "${dir}/$note.md"
      ''})
      bindsym $win+n $exec $term ${getExe pkgs.zsh} -c '${getExe' pkgs.networkmanager "nmcli"} device wifi rescan && unset COLORTERM && TERM=xterm-old ${getExe' pkgs.networkmanager "nmtui'"}"}
      bindsym $win+b $exec $term ${getExe pkgs.bluetuith} --no-warning
      bindsym $win+Shift+b $exec ${pkgs.writeShellScript "bluetooth-toogle" ''
        if ${getExe' pkgs.bluez "bluetoothctl"} info ${airpods} | grep -q "Connected: yes"; then
          echo -e "disconnect ${airpods}\nquit" | ${getExe' pkgs.bluez "bluetoothctl"}
        else
          echo -e "connect ${airpods}\nquit" | ${getExe' pkgs.bluez "bluetoothctl"}
        fi
      ''}
      bindsym $win+Shift+n $exec ${getExe' pkgs.networkmanager "nmcli"} device wifi rescan
      bindsym $win+w $exec $browser
      bindsym $win+Shift+p $exec ${getExe pkgs.copyq} show
      bindsym $win+u $exec ${getExe' pkgs._1password-gui "1password"} --quick-access
      bindsym $win+d $exec ${getExe j4-dmenu-desktop} --no-generic -d '${getExe pkgs.bemenu} -p "DESKTOP"'

      bindsym $win+i $exec ${getExe' pkgs.polybar "polybar-msg"} cmd toggle
      bindsym $win+x $exec ${getExe' pkgs.dunst "dunstctl"} close-all
      bindsym $win+r $exec ${getExe' pkgs.dunst "dunstctl"} history-pop
      bindsym $win+a $exec ${getExe' pkgs.dunst "dunstctl"} action

      bindsym $win+o $exec ${getExe pkgs.gromit-mpx} --toggle
      bindsym F9 $exec ${getExe pkgs.gromit-mpx} --toggle
      bindsym $win+Shift+o $exec ${getExe pkgs.gromit-mpx} --clear

      bindsym $win+p $exec ${getExe pkgs.scripts.powermenu}
      bindsym --release $win+Shift+c exec ${getExe pkgs.scripts.color-picker}
      bindsym --release $win+Shift+m exec $tmux -s 'xprop' '${getExe' pkgs.xorg.xprop "xprop"} exec $SHELL'

      bindsym Print $exec ${getExe pkgs.scripts.screenshot} region
      bindsym $alt+Sys_Req $exec ${getExe pkgs.scripts.screenshot} window
      bindsym Shift+Print $exec ${getExe pkgs.scripts.screenshot} monitor

      bindsym XF86AudioRaiseVolume $exec ${getExe pkgs.scripts.change-volume} up
      bindsym XF86AudioLowerVolume $exec ${getExe pkgs.scripts.change-volume} down
      bindsym XF86AudioMute $exec ${getExe pkgs.scripts.change-volume} mute
      bindsym XF86AudioNext $exec ${getExe pkgs.playerctl} next
      bindsym XF86AudioPrev $exec ${getExe pkgs.playerctl} previous
      bindsym XF86AudioPlay $exec ${getExe pkgs.playerctl} play-pause
      bindsym XF86MonBrightnessDown $exec ${getExe pkgs.scripts.change-brightness} down
      bindsym XF86MonBrightnessUp $exec ${getExe pkgs.scripts.change-brightness} up

      bindsym $win+Shift+r restart
      bindsym $win+h focus left
      bindsym $win+j focus down
      bindsym $win+k focus up
      bindsym $win+l focus right
      bindsym $win+q kill
      bindsym $win+f fullscreen toggle
      bindsym $win+Return floating toggle
      bindsym $win+g focus mode_toggle

      bindsym $win+Ctrl+h move left $window-move-amount
      bindsym $win+BackSpace move left $window-move-amount

      bindsym $win+Ctrl+j move down $window-move-amount
      bindsym $win+Ctrl+Tab move down $window-move-amount

      bindsym $win+Ctrl+k move up $window-move-amount
      bindsym $win+Ctrl+Shift+Tab move up $window-move-amount

      bindsym $win+Ctrl+l move right $window-move-amount

      bindsym $win+c move position center

      bindsym $win+Shift+h resize shrink width 30 px or 30 ppt
      bindsym $win+Shift+j resize grow height 30 px or 30 ppt
      bindsym $win+Shift+k resize shrink height 30 px or 30 ppt
      bindsym $win+Shift+l resize grow width 30 px or 30 ppt

      bindsym $win+Shift+equal workspace $ws1
      bindsym $win+bracketleft workspace $ws2
      bindsym $win+Shift+bracketleft workspace $ws3
      bindsym $win+Shift+9 workspace $ws4
      bindsym $win+Shift+7 workspace $ws5
      bindsym $win+equal workspace $ws6
      bindsym $win+Shift+0 workspace $ws7
      bindsym $win+Shift+bracketright workspace $ws8
      bindsym $win+bracketright workspace $ws9
      bindsym $win+Shift+5 workspace $ws10

      bindsym $win+1 move container to workspace $ws1
      bindsym $win+2 move container to workspace $ws2
      bindsym $win+3 move container to workspace $ws3
      bindsym $win+4 move container to workspace $ws4
      bindsym $win+5 move container to workspace $ws5
      bindsym $win+6 move container to workspace $ws6
      bindsym $win+7 move container to workspace $ws7
      bindsym $win+8 move container to workspace $ws8
      bindsym $win+9 move container to workspace $ws9
      bindsym $win+0 move container to workspace $ws10

      assign [class="^spotify$"] 4
      assign [title="^ncspot$"] 4

      for_window [window_role="About"] floating enable
      for_window [window_role="Organizer"] floating enable
      for_window [window_role="Preferences"] floating enable
      for_window [window_role="bubble"] floating enable
      for_window [window_role="page-info"] floating enable
      for_window [window_role="pop-up"] floating enable
      for_window [window_role="task_dialog"] floating enable
      for_window [window_role="toolbox"] floating enable
      for_window [window_role="webconsole"] floating enable
      for_window [window_type="dialog"] floating enable
      for_window [window_type="menu"] floating enable
      for_window [title="^Friends List$"] floating enable
      for_window [title="^filechooser$"] floating enable
      for_window [class="Pqiv"] floating enable
      for_window [class="1Password"] floating enable
      for_window [class="Org.gnome.NautilusPreviewer"] floating enable
      for_window [class="Main"] floating enable
      for_window [class="Matplotlib"] floating enable
      for_window [class="gnome-calculator"] floating enable
      for_window [class="Ryujinx"] floating enable
      for_window [class=".*"] border pixel 1
      for_window [floating] move position center
      for_window [window_role="Popup"] border pixel 0

      for_window [title="Steam - Update News"] floating enable
      assign [class="^.gamescope-wrapped$"] 6

      $exec ${getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd --all
      $exec ${getExe pkgs.gromit-mpx}
      $exec ${getExe pkgs.polybar}
      $exec ${getExe' pkgs.i3 "i3-msg"} workspace 1
      $exec kdeconnect-cli --refresh
      $exec ${getExe pkgs.xorg.xset} s off -dpms

      # $exec_always ${pkgs.writeShellScript "set-wallpaper" ''
          # wallpapers="$HOME/pictures/wallpapers/$(< $TINTED_FILE)"
          # if [[ -d $wallpapers ]]; then
          #   shuf -e -n1 --random-source=<(date +%Y%m%d | md5sum) \
          #     ''${wallpapers}/* | \
          #     ${getExe' pkgs.findutils "xargs"} ${getExe pkgs.feh} --no-fehbg --bg-fill
          # else
          #   ${getExe pkgs.feh} --no-fehbg --bg-fill ${config.me.flakeDir}/.assets/wallpaper.png
          # fi
        # ''}

      $exec_always ${getExe' pkgs.hsetroot "hsetroot"} -solid "$(xrdb -query | grep 'bg0:' | cut -f2)"
      $exec_always ${getExe pkgs.i3altlayout}
      $exec_always ${getExe' pkgs.polybar "polybar-msg"} cmd restart

    '';

  packages = [ pkgs.libinput-gestures ];

  hj.xdg.config.files."libinput-gestures.conf".text =
    let
      xdo = getExe pkgs.xdotool;
    in
    ''
      gesture swipe left 3 i3-msg workspace next
      gesture swipe right 3 i3-msg workspace prev
      gesture swipe down 3 ${getExe pkgs.bash} -c "${xdo} key super+f; ${xdo} key alt+c"
      gesture swipe up 3 ${getExe pkgs.bash} -c "${xdo} key super+f; ${xdo} key alt+c"
    '';

  # user needs to be in the input group
  systemd.user.services.libinput-gestures = {
    path = [ pkgs.i3 ];
    partOf = [ "graphical-session.target" ];

    serviceConfig.ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures";
    restartTriggers = [
      "${config.hj.xdg.config.files."libinput-gestures.conf".source}"
    ];

    wantedBy = [ "graphical-session.target" ];
  };
}
