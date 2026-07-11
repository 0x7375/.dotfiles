{
  flake.modules.nixos.core =
    {
      pkgs,
      ...
    }:
    {
      persist.directories = [ "/var/lib/bluetooth" ];

      packages = [ pkgs.adw-bluetooth ];

      hardware.bluetooth = {
        enable = true;
        settings = {
          General = {
            MultiProfile = "multiple";
            Privacy = "device";
            FastConnectable = true;
          };
        };
      };
    };

  flake.modules.nixos.woz = { pkgs, ... }: {
    # from: https://github.com/christian-korneck/asahi-bt-a2dp-fix
    # related to: https://github.com/bluez/bluez/issues/1976
    systemd.services.bt-a2dp-fix = {
      description = "Bluetooth A2DP stutter fix for Apple Silicon BCM4378";
      after = [ "bluetooth.target" ];
      wants = [ "bluetooth.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [
        pkgs.bluez
        pkgs.expect # unbuffer is from expect
      ];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 5;
        ExecStart = pkgs.writeShellScript "bt-a2dp-fix" ''
          unbuffer bluetoothctl --monitor | while read -r line; do
            if [[ "$line" =~ Device.*([0-9A-F:]{17}).*Connected:\ yes ]]; then
              mac="''${BASH_REMATCH[1]}"
              sleep 2
              bluetoothctl info "$mac" | grep -q "Audio Sink" || continue
              handle=$(hcitool con | grep -i "$mac" | grep -oP 'handle \K[0-9]+')
              [[ -n "$handle" ]] && hcitool cmd 0x3f 0x57 "$(printf 0x%02X $handle)" 0x00 0x01
            fi
          done
        '';
      };
    };

    services.pipewire.wireplumber.extraConfig = {
      "51-bluetooth-no-mic" = {
        "monitor.bluez.properties" = {
          "bluez5.roles" = [
            "a2dp_sink"
            "a2dp_source"
          ];
        };
      };
      "50-bt-latency" = {
        "monitor.bluez.rules" = [
          {
            matches = [ { "node.name" = "~bluez_output.*"; } ];
            actions.update-props = {
              "latency.internal.ns" = 100000000;
            };
          }
        ];
      };
    };
  };
}
