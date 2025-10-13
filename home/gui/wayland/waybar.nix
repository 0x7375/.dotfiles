{
  pkgs,
  myLib,
  config,
  lib,
  ...
}:
let
  palette = myLib.palette;
in
lib.mkIf (config.me.gui.displayServer == "wayland") {
  systemd.user.services.waybar = {
    Unit = {
      StartLimitBurst = 30;
      X-Restart-Triggers = lib.mkForce [ ];
      X-SwitchMethod = "reload";
    };
    Service = {
      ExecStartPre = "${lib.getExe pkgs.scripts.waybar-output}";
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      primary = {
        layer = "top";
        height = 35;
        margin = "0";
        include = [ "~/.config/waybar/output.json" ];

        modules-left = [
          # "custom/hostname"
          # "custom/separator"
          "hyprland/window"
        ];

        modules-center = [ "hyprland/workspaces" ];

        modules-right = [
          "cpu"
          "custom/separator"
          "memory"
          "custom/separator"
        ]
        ++ (
          if config.me.hostname == "ryusei" then
            [
              "battery"
              "custom/separator"
            ]
          else
            [ ]
        )
        ++ [
          "network"
          "custom/separator"
          "clock"
        ];

        "custom/hostname" = {
          type = "custom/text";
          format = "~${config.me.hostname}";
          tooltip = false;
        };

        "custom/separator" = {
          "format" = " ";
          "interval" = "once";
          "tooltip" = false;
        };

        "hyprland/workspaces" = {
          on-click = "activate";
          all-outputs = true;
          active-only = false;
          show-special = false;
          persistent-workspaces = {
            "*" = 1;
          };
        };

        "hyprland/window" = {
          format = " {}";
          "rewrite" = {
            "(.*) Zen Browser" = " zen";
            "(.*) LibreWolf" = " librewolf";
            "(.*) Firefox" = " firefox";
          };
        };

        cpu = {
          interval = 3;
          format = "cpu: {usage}%";
        };

        memory = {
          interval = 3;
          format = "ram: {percentage}%";
        };

        battery = {
          interval = 5;
          bat = "BAT0";
          format = "pow: {capacity}%";
          format-charging = "pow: ~{capacity}%";
        };

        network = {
          interval = 5;
          interface = "wlan0";
          format-wifi = "net: {essid}";
          format-ethernet = "net: eth";
          format-disconnected = "net: x";
          tooltip = false;
          max-length = 13;
        };

        clock = {
          interval = 1;
          format = "{:%a %d %b - %H:%M}";
          tooltip = false;
        };
      };
    };

    style = # css
      ''
        * {
          font-family: Mononoki Nerd Font;
          font-size: ${toString myLib.bar.font-size}pt;
          padding: 0;
          margin: 0;
          border: none;
          border-radius: 0;
        }

        window#waybar {
          background-color: ${palette.bg0_dark};
          color: ${palette.fg0};
        }

        .modules-left,
        .modules-center,
        .modules-right {
          background-color: transparent;
        }

        #custom-hostname {
          padding: 0 8px;
          color: ${palette.fg0};
        }

        #workspaces button {
          padding: 0 8px;
          color: ${palette.bg2};
          background-color: transparent;
        }

        #workspaces button.active {
          color: ${palette.fg0};
        }

        #workspaces button.urgent {
          color: ${palette.bg2};
        }

        #cpu,
        #memory,
        #battery,
        #network,
        #clock {
          padding: 0 8px;
        }

        #battery.warning {
          color: ${palette.yellow};
        }

        #battery.critical {
          color: ${palette.red};
        }

        #network.disconnected {
          color: ${palette.fg3};
        }
      '';
  };
}
