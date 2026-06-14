{
  pkgs,
}:
pkgs.writeShellApplication {
  name = "lock";
  runtimeInputs = with pkgs; [
    my.noctalia
    networkmanager
  ];
  bashOptions = [ ];
  text = ''
    safe() {
      nmcli -g NAME connection show --active | grep -Fxq -e "home-wifi" -e "away_1" -e "away_2"
    }

    case "$1" in
    lock)
      if ! safe; then
        noctalia msg session lock
      fi
    ;;
    *)
      if ! safe; then
        noctalia msg session lock-and-suspend
      else
        noctalia msg session suspend
      fi
    ;;
    esac
  '';
}
