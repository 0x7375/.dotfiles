{
  flake.modules.nixos.wayland =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (lib) getExe;
    in
    {
      sops.secrets.coordinates.owner = config.me.user;

      location = {
        latitude = 0.0;
        longitude = 0.0;
      };

      packages = [ pkgs.gammastep ];

      systemd.user.services.gammastep = {
        description = "gammastep";
        wantedBy = [ "mango-session.target" ];
        partOf = [ "mango-session.target" ];
        after = [ "noctalia.service" ];
        requires = [ "noctalia.service" ];
        serviceConfig = {
          ExecStartPre = pkgs.writeShellScript "wait-for-noctalia" ''
            until ${lib.getExe pkgs.my.noctalia} msg status >/dev/null 2>&1; do
              sleep 0.1
            done
          '';
          ExecStart = pkgs.writeShellScript "gammastep-start" ''
            set -euo pipefail
            exec ${lib.getExe pkgs.gammastep} \
              -l "$(cat ${config.sops.secrets.coordinates.path})" \
              -t 6500:3000 \
              -b 1.0:1.0 \
              -v
          '';
          Restart = "always";
          RestartSec = 3;
        };
      };

      hj.xdg.config.files."gammastep/hooks/brightness.sh" = {
        enable = true;
        executable = true;
        text = # bash
          ''
            #!${getExe pkgs.bash}

            brightness_day=85
            brightness_transition=40
            brightness_night=15

            set_brightness() {
              ${getExe pkgs.my.noctalia} msg theme-mode-set $1
              shift

              ${getExe pkgs.brillo} -S "$1" &
              for display in 1 2; do
                ${getExe pkgs.ddcutil} --display $display setvcp 10 "$1" &
              done
            }

            if [[ $1 == "period-changed" ]]; then
              case $3 in
                night) set_brightness "dark" "$brightness_night" ;;
                transition) set_brightness "dark" "$brightness_transition" ;;
                daytime) set_brightness "light" "$brightness_day" ;;
              esac
            fi
          '';
      };
    };

  flake.modules.nixos.laptop = {
    powerManagement.resumeCommands = # bash
      ''
        systemctl restart --user gammastep
      '';
  };
}
