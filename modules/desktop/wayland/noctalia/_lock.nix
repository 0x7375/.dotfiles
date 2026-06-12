{
  config,
  pkgs,
}:
pkgs.writeShellApplication {
  name = "lock";
  runtimeInputs = with pkgs; [
    wirelesstools
    my.noctalia
  ];
  bashOptions = [ ];
  text = ''
    current_ssid=$(iwgetid -r || true)
    home_ssid=$(cat "${config.sops.secrets.home_ssid.path}")

    [[ "$current_ssid" == "$home_ssid" ]] && exit 0

    case "$1" in
    lock-and-suspend) noctalia msg session lock-and-suspend ;;
    lock) noctalia msg session lock ;;
    *) noctalia msg session lock-and-suspend ;;
    esac
  '';
}
