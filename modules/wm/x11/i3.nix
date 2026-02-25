{
  mkNixos,
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (config.me) wm;
  inherit (lib) getExe getExe';
in
lib.mkIf (config.me.wm.displayServer == "xorg") (mkNixos {
  hj.xdg.config.files."i3/config".text =
    let
      airpods = "D4:68:AA:88:8E:32";
      dir = "$HOME/notes";
    in
    ''
      set $term ${getExe pkgs.${wm.terminal}} -e
      set $browser ${wm.browser}
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

      # hide tab title
      font pango:monospace 0.000000
      floating_modifier $win
      default_border pixel 0
      default_floating_border pixel 1
      hide_edge_borders smart
      focus_wrapping no
      focus_follows_mouse yes
      focus_on_window_activation focus
      mouse_warping output
      workspace_layout tabbed
      workspace_auto_back_and_forth no

      set_from_resource $inactive bg0 #000000
      set_from_resource $active fg2 #000000

      #                        border    background text      indicator child_border
      client.focused           $active   $active    $active   $active   $active
      client.focused_inactive  $inactive $inactive  $inactive $inactive $inactive
      client.unfocused         $inactive $inactive  $inactive $inactive $inactive
      client.urgent            $active   $active    $active   $active   $active
      client.placeholder       $inactive $inactive  $inactive $inactive $inactive
      client.background        $inactive

      bindsym $win+t $exec $term ${getExe pkgs.my.tmux-sessionizer} ~/
      bindsym $win+Shift+t $exec {getExe pkgs.${wm.terminal}

      bindsym $win+s $exec $term ${getExe pkgs.my.tmux-sshr}
      bindsym $win+Shift+s $exec ${getExe pkgs.my.swap-theme}
      bindsym $win+e $exec $term ${getExe pkgs.lf}
      bindsym $win+Shift+e $exec $term sudo ${getExe pkgs.lf}
      bindsym $win+m $exec $term $(${pkgs.writeShellScript "open-note" ''
        note=$(ls ${dir} | sed 's/\.md$//' | bemenu -p "NOTE")
        [ -n "$note" ] && echo $EDITOR "${dir}/$note.md"
      ''})
      bindsym $win+n $exec $term ${getExe pkgs.zsh} -c '${getExe' pkgs.networkmanager "nmcli"} device wifi rescan && unset COLORTERM && TERM=xterm-old ${getExe' pkgs.networkmanager "nmtui'"}"}
      bindsym $win+Shift+b $exec ${pkgs.writeShellScript "bluetooth-toogle" ''
        if ${getExe' pkgs.bluez "bluetoothctl"} info ${airpods} | grep -q "Connected: yes"; then
          echo -e "disconnect ${airpods}\nquit" | ${getExe' pkgs.bluez "bluetoothctl"}
        else
          echo -e "connect ${airpods}\nquit" | ${getExe' pkgs.bluez "bluetoothctl"}
        fi
      ''}
      bindsym $win+Shift+n $exec ${getExe' pkgs.networkmanager "nmcli"} device wifi rescan
      bindsym $win+w $exec $browser
      bindsym $win+b $exec ${pkgs.writeShellScript "open bookmark" ''
        OPENER="xdg-open"
        [[ $OSTYPE == darwin* ]] && OPENER="open"

        file="$HOME/notes/Bookmarks.md"
        [[ ! -f $file ]] && exit

        selection=$(awk -F': ' '{print $1}' "$file" | bemenu -i -p "BOOKMARK")
        [[ -z "$selection" ]] && exit

        if [[ $selection == !* ]]; then
          bang="''${selection%% *}"
          query="''${selection#* }"
          query="''${query// /+}"
          
          case "$bang" in
            "!y") url="https://www.youtube.com/results?search_query=$query" ;;
            "!g") url="https://google.com/search?q=$query" ;;
            "!gi") url="https://google.com/search?q=$query&tbm=isch" ;;
            "!s") url="https://www.startpage.com/do/dsearch?prfe=d7a6edf2bdae7d159fd3c7281470fb1b1611b9ebc58099d433766aab83750a24485b18c6615e9979c5ef4f823efb2326568630359a4cfaca9f87b8eda4b78324a831f096405c6b39160f84ca&query=$query" ;;
            "!b") url="https://search.brave.com/search?q=$query" ;;
            "!bi") url="https://search.brave.com/images?q=$query" ;;
            "!p") url="https://mynixos.com/search?q=package+$query" ;;
            "!o") url="https://mynixos.com/search?q=option+$query" ;;
            "!n") url="https://noogle.dev/q?term=$query" ;;
            "!u") url="https://history.nix-packages.com/search?search=$query" ;;
            "!h") url="https://github.com/search?type=code&q=$query" ;;
            "!w") url="https://en.wikipedia.org/wiki/Special:Search?search=$query" ;;
            "!c") url="https://conjugaison.bescherelle.com/verbes/$query" ;;
            *) url="https://google.com/search?q=$query" ;;
          esac
        else
          url=$(awk -F': ' -v sel="$selection" '$1 == sel {print $2}' "$file")
        fi

        [[ -n "$url" ]] && $OPENER "$url"
      ''}

      bindsym $win+Shift+p $exec ${getExe pkgs.copyq} show
      bindsym $win+u $exec ${getExe' pkgs._1password-gui "1password"} --quick-access
      bindsym $win+d $exec ${getExe pkgs.j4-dmenu-desktop} --no-generic -d '${getExe pkgs.bemenu} -p "DESKTOP"'

      bindsym $win+i $exec ${getExe' pkgs.polybar "polybar-msg"} cmd toggle
      bindsym $win+x $exec ${getExe' pkgs.dunst "dunstctl"} close-all
      bindsym $win+r $exec ${getExe' pkgs.dunst "dunstctl"} history-pop
      bindsym $win+a $exec ${getExe' pkgs.dunst "dunstctl"} action

      bindsym $win+o $exec ${getExe pkgs.gromit-mpx} --toggle
      bindsym F9 $exec ${getExe pkgs.gromit-mpx} --toggle
      bindsym $win+Shift+o $exec ${getExe pkgs.gromit-mpx} --clear

      bindsym $win+p $exec ${getExe pkgs.my.powermenu}
      bindsym --release $win+Shift+c exec ${getExe pkgs.my.color-picker}
      bindsym --release $win+Shift+m exec "$term sh -c '${getExe' pkgs.xorg.xprop "xprop"}; exec $SHELL'"

      bindsym Print $exec ${getExe pkgs.my.screenshot} region
      bindsym $alt+Sys_Req $exec ${getExe pkgs.my.screenshot} window
      bindsym Shift+Print $exec ${getExe pkgs.my.screenshot} monitor

      bindsym XF86AudioRaiseVolume $exec ${getExe pkgs.my.change-volume} up
      bindsym XF86AudioLowerVolume $exec ${getExe pkgs.my.change-volume} down
      bindsym XF86AudioMute $exec ${getExe pkgs.my.change-volume} mute
      bindsym XF86AudioNext $exec ${getExe pkgs.playerctl} next
      bindsym XF86AudioPrev $exec ${getExe pkgs.playerctl} previous
      bindsym XF86AudioPlay $exec ${getExe pkgs.playerctl} play-pause
      bindsym XF86MonBrightnessDown $exec ${getExe pkgs.my.change-brightness} down
      bindsym XF86MonBrightnessUp $exec ${getExe pkgs.my.change-brightness} up

      bindsym $win+Shift+r restart
      bindsym $win+h focus left
      bindsym $win+j focus down
      bindsym $win+k focus up
      bindsym $win+l focus right
      bindsym $win+q kill
      bindsym $win+f fullscreen toggle
      bindsym $win+g layout toggle splith tabbed

      bindsym $win+Return floating toggle
      bindsym $win+Shift+g focus mode_toggle

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

      bindsym $win+1 workspace $ws1
      bindsym $win+2 workspace $ws2
      bindsym $win+3 workspace $ws3
      bindsym $win+4 workspace $ws4
      bindsym $win+5 workspace $ws5
      bindsym $win+6 workspace $ws6
      bindsym $win+7 workspace $ws7
      bindsym $win+8 workspace $ws8
      bindsym $win+9 workspace $ws9
      bindsym $win+0 workspace $ws10

      bindsym $win+Shift+1 move container to workspace $ws1
      bindsym $win+Shift+2 move container to workspace $ws2
      bindsym $win+Shift+3 move container to workspace $ws3
      bindsym $win+Shift+4 move container to workspace $ws4
      bindsym $win+Shift+5 move container to workspace $ws5
      bindsym $win+Shift+6 move container to workspace $ws6
      bindsym $win+Shift+7 move container to workspace $ws7
      bindsym $win+Shift+8 move container to workspace $ws8
      bindsym $win+Shift+9 move container to workspace $ws9
      bindsym $win+Shift+0 move container to workspace $ws10

      assign [class="^${wm.browser}$"] 3
      assign [class="^spotify$"] 4
      assign [class="^SimpMusic$"] 4
      assign [title="^ncspot$"] 4
      assign [class="^discord$"] 4

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
      for_window [class="Ryujinx"] floating enable
      for_window [class=".*"] border pixel 1
      for_window [floating] move position center
      for_window [window_role="Popup"] border pixel 0

      for_window [title="Bitwarden Web vault"] floating disable

      for_window [title="Steam - Update News"] floating enable
      # assign [class="^.gamescope-wrapped$"] 6

      $exec ${getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd --all
      $exec ${getExe pkgs.gromit-mpx}
      $exec ${getExe pkgs.polybar}
      $exec ${getExe' pkgs.i3 "i3-msg"} workspace 1
      $exec ${getExe' pkgs.kdePackages.kdeconnect-kde "kdeconnect-indicator"}
      $exec ${getExe pkgs.xorg.xset} s off -dpms

      # makes arbtt work properly
      $exec ${getExe' pkgs.xorg.xprop "xprop"} -root -f _NET_CLIENT_LIST 32a -set _NET_CLIENT_LIST 0

      $exec_always ${getExe' pkgs.hsetroot "hsetroot"} -solid "$(xrdb -query | grep 'bg0:' | cut -f2)"
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
})
