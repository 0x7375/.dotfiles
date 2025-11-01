{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf (config.me.gui.displayServer == "xorg") {
  hj.xdg.config.files."redshift/hooks/brightness.sh" = {
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
