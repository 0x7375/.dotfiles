{
  pkgs,
  mkNixos,
  config,
  lib,
  ...
}:

let
  inherit (lib) getExe getExe';
in
lib.mkIf (config.me.wm.displayServer == "xorg") (mkNixos {
  packages = [ pkgs.polybar ];

  me.wm = {
    bindings."Mod+i" = "${lib.getExe' pkgs.polybar "polybar-msg"} cmd toggle";

    startup =
      let
        polybar = getExe pkgs.polybar;
        polybar-msg = getExe' pkgs.polybar "polybar-msg";
      in
      {
        inherit polybar;
        polybar-restart = {
          cmd = "${polybar-msg} cmd restart";
          always = true;
        };

        polybar-network = {
          cmd = "${getExe' pkgs.networkmanager "nmcli"} monitor | while read -r _; do ${polybar-msg} action network hook 0; done";
          always = true;
        };

        polybar-bt = {
          cmd = pkgs.writeShellScript "polybar-bt" ''
            ${getExe' pkgs.dbus "dbus-monitor"} --system \
              "type='signal',interface='org.freedesktop.DBus.Properties',path_namespace='/org/bluez'" \
              | grep --line-buffered '"Connected"' \
              | while read -r _; do
                  ${polybar-msg} action bluetooth hook 0
                done
          '';
          always = true;
        };

        polybar-music = {
          cmd = pkgs.writeShellScript "polybar-music" ''
            ${getExe pkgs.playerctl} --follow metadata --format '{{status}}{{title}}' \
              | while read -r _; do
                  ${polybar-msg} action music hook 0
                done
          '';
          always = true;
        };

        polybar-clock = {
          # sleep to next minute boundary, then tick every minute
          cmd = pkgs.writeShellScript "polybar-clock" ''
            sleep $(( 60 - $(date +%S) ))
            while true; do ${polybar-msg} action datetime hook 0; sleep 60; done
          '';
          always = true;
        };
      };
  };

  hj.xdg.config.files."polybar/config.ini".text =
    let
      inherit (config.me) hostname wm;
    in
    # ini
    ''
      [bar/main]
      background=''${xrdb:bg0_dark}
      border-size=0pt
      enable-ipc=true
      font-0=Mononoki Nerd Font:pixelsize=${toString wm.barFontSize};4
      foreground=''${xrdb:fg0}
      height=${toString wm.barHeight}
      module-margin=0
      modules-center=i3
      modules-left=xwindow music
      modules-right=cpu memory bluetooth network battery datetime
      padding=1
      radius=0
      separator=" "
      separator-padding=1
      width=100%

      [module/battery]
      battery=BAT0
      format-charging=<label-charging>
      format-discharging=<label-discharging>
      label-charging=pow: ~%percentage%%
      label-discharging=pow: %percentage%%
      label-full=pow: %percentage%%
      label-low=pow: %percentage%%
      poll-interval=0
      type=internal/battery

      [module/cpu]
      format=cpu: <label>
      interval=5
      type=internal/cpu

      [module/i3]
      label-focused=%index%
      label-focused-foreground=''${xrdb:fg0}
      label-focused-padding=1
      label-unfocused=%index%
      label-unfocused-foreground=''${xrdb:bg2}
      label-unfocused-padding=1
      label-urgent=%index%
      label-urgent-foreground=''${xrdb:bg2}
      label-urgent-padding=1
      label-visible=%index%
      label-visible-foreground=''${xrdb:bg2}
      label-visible-padding=1
      pin-workspaces=true
      type=internal/i3

      [module/memory]
      format=ram: <label>
      interval=5
      type=internal/memory

      [module/music]
      type=custom/ipc
      hook-0=${pkgs.writeShellScript "polybar-music-hook" ''
        status=$(${getExe pkgs.playerctl} status)
        if [[ "$status" = "Playing" ]]; then
          info=$(${getExe pkgs.playerctl} metadata --format '|   {{artist}} - {{title}}' 2> /dev/null)
          if [[ ''${#info} -gt 40 ]]; then
            echo "''${info:0:40}~"
          else
            echo "$info"
          fi
        else
          echo ""
        fi
      ''}
      initial=1

      [module/network]
      type=custom/ipc
      hook-0=${pkgs.writeShellScript "polybar-network-hook" ''
        ssid=$(${getExe' pkgs.networkmanager "nmcli"} -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
        if [ -n "$ssid" ]; then
          if [[ ''${#ssid} -gt 7 ]]; then
            echo "net: ''${ssid:0:7}~"
          else
            echo "net: $ssid"
          fi
        else
          echo "net: x"
        fi
      ''}
      initial=1

      [module/bluetooth]
      type=custom/ipc
      hook-0=bluetoothctl info | grep "Name:" | sed 's/.*Name: /bt: /'
      initial=1

      [module/datetime]
      type=custom/ipc
      hook-0=date '+%a %d %b - %H:%M'
      initial=1

      [module/tray]
      type=internal/tray

      [module/xwindow]
      label=" %title%"
      label-empty=~${hostname}
      label-maxlen=40
      type=internal/xwindow

      [settings]
      pseudo-transparency=true
      screenchange-reload=true
    '';
})
