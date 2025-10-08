{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf (config.me.gui.displayServer == "wayland" && config.me.secrets.enable) {
  sops.secrets.coordinates = { };

  services.gammastep = {
    enable = true;
    longitude = "0";
    latitude = "0";
  };

  systemd.user.services.gammastep.Service.ExecStart = lib.mkForce (
    pkgs.writeShellScript "gammastep-start" ''
      set -euo pipefail
      exec ${lib.getExe pkgs.gammastep} \
        -l "$(cat ${config.sops.secrets.coordinates.path})" \
        -t 6500:3000 \
        -b 1.0:1.0 \
        -v
    ''
  );

  xdg.configFile."gammastep/hooks/brightness.sh" = {
    enable = true;
    executable = true;
    text = # bash
      ''
        #!${lib.getExe pkgs.bash}
        brightness_day=85
        brightness_transition=40
        brightness_night=15

        set_brightness() {
            ${lib.getExe pkgs.brillo} -S "$1" &
            for display in 1 2; do
              ${lib.getExe pkgs.ddcutil} --display $display setvcp 10 "$1" &
            done
        }

        if [[ $1 == "period-changed" ]]; then
            case $3 in
                night) set_brightness "$brightness_night" ;;
                transition) set_brightness "$brightness_transition" ;;
                daytime) set_brightness "$brightness_day" ;;
            esac
        fi
      '';
  };
}
