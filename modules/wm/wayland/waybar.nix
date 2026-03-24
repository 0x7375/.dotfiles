{
  flake.nixos.wayland =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      playerctl = lib.getExe pkgs.playerctl;
    in
    {
      programs.waybar.enable = true;

      systemd.user.services.waybar = {
        unitConfig = {
          StartLimitBurst = 30;
          X-Restart-Triggers = lib.mkForce [ ];
          X-SwitchMethod = "reload";
        };
        serviceConfig = {
          ExecStartPre = "${lib.getExe pkgs.my.waybar-output}";
        };
      };

      hj.xdg.config.files."waybar/config".text = builtins.toJSON {
        layer = "top";
        height = 35;
        margin = "0";
        include = [ "~/.config/waybar/output.json" ];

        modules-left = [
          "hyprland/window"
          "custom/music"
        ];

        modules-center = [ "hyprland/workspaces" ];

        modules-right = [
          "cpu"
          "memory"
          "custom/bluetooth"
          "custom/network"
          "battery"
          "custom/clock"
        ];

        "hyprland/workspaces" = {
          on-click = "activate";
          all-outputs = true;
          active-only = false;
          show-special = false;
          persistent-workspaces."*" = 1;
        };

        "hyprland/window" = {
          format = " {}";
          rewrite =
            let
              host = " ~${config.me.hostname}";
            in
            {
              " " = host;
            };
          max-length = 40;
        };

        "custom/music" = {
          exec = pkgs.writeShellScript "waybar-music" ''
            ${playerctl} metadata --follow --format '{{status}}|   {{artist}} - {{title}}' 2>/dev/null | while read -r line; do
              if [[ "$line" == Playing* ]]; then
                info="''${line#*|   }"
                if [[ ''${#info} -gt 40 ]]; then
                  echo "| ''${info:0:40}~"
                else
                  echo "| $info"
                fi
              else
                echo ""
              fi
            done
          '';
          tooltip = false;
          escape = true;
        };

        cpu = {
          interval = 5;
          format = "cpu: {usage}%";
        };

        memory = {
          interval = 5;
          format = "ram: {percentage}%";
        };

        "custom/bluetooth" = {
          exec = pkgs.writeShellScript "waybar-bluetooth" ''
            update() {
              name=$(${lib.getExe' pkgs.bluez "bluetoothctl"} info | grep "Name:" | sed 's/.*Name: //')
              if [ -n "$name" ]; then
                echo "bt: $name"
              else
                echo ""
              fi
            }

            update

            ${lib.getExe' pkgs.dbus "dbus-monitor"} --system "type='signal',interface='org.freedesktop.DBus.Properties',path_namespace='/org/bluez'" | while read -r _; do
              update
            done
          '';
          tooltip = false;
        };

        battery = {
          interval = 5;
          bat = "BAT0";
          format = "pow: {capacity}%";
          format-charging = "pow: ~{capacity}%";
          format-discharging = "pow: ~{capacity}% - {power:.1f}W";
        };

        "custom/network" = {
          exec = pkgs.writeShellScript "waybar-network" ''
            update() {
              ssid=$(${lib.getExe' pkgs.networkmanager "nmcli"} -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
              if [ -n "$ssid" ]; then
                if [[ ''${#ssid} -gt 7 ]]; then
                  echo "{\"text\": \"net: ''${ssid:0:7}~\", \"class\": \"connected\"}"
                else
                  echo "{\"text\": \"net: $ssid\", \"class\": \"connected\"}"
                fi
              else
                echo "{\"text\": \"net: x\", \"class\": \"disconnected\"}"
              fi
            }

            update

            ${lib.getExe' pkgs.networkmanager "nmcli"} monitor | while read -r _; do
              update
            done
          '';
          return-type = "json";
          tooltip = false;
        };

        "custom/clock" = {
          exec = pkgs.writeShellScript "waybar-clock" ''
            while true; do
              date '+%d/%m - %H:%M'
              sleep $(( 60 - $(date +%S) ))
            done
          '';
          tooltip = false;
        };
      };

      tinted.files.".config/waybar/style.css".text =
        p: # css
        ''
          * {
            font-family: Mononoki Nerd Font;
            font-size: ${toString config.me.wm.barFontSize}pt;
            padding: 0;
            margin: 0;
            border: none;
            border-radius: 0;
          }

          .modules-left,
          .modules-center,
          .modules-right {
            background-color: transparent;
          }

          #cpu,
          #memory,
          #custom-bluetooth,
          #custom-network,
          #battery,
          #custom-music,
          #hyprland-window,
          #custom-clock {
            padding: 0 12px;
          }

          #custom-network.disconnected {
            color: ${p.fg3};
          }

          window#waybar {
            background-color: ${p.bg0_dark};
            color: ${p.fg0};
          }

          #workspaces button {
            padding: 0 8px;
            background-color: transparent;
          }

          #workspaces button.active {
            color: ${p.fg0};
          }

          #workspaces button {
            color: ${p.bg2};
          }
        '';
    };
}
