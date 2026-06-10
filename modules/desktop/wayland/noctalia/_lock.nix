{
  lib,
  config,
  pkgs,
}:
pkgs.writeShellApplication {
  name = "lock";
  text = ''
    current_ssid=$(${lib.getExe' pkgs.wirelesstools "iwgetid"} -r)
    home_ssid=$(cat "${config.sops.secrets.home_ssid.path}")

    [[ "$current_ssid" == "$home_ssid" ]] && exit 0

    case "$1" in
    lock-and-suspend) noctalia msg session lock-and-suspend ;;
    lock) noctalia msg session lock ;;
    esac
  '';
}
