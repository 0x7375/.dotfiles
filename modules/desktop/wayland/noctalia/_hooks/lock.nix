{
  lib,
  config,
  pkgs,
}:
pkgs.writeShellApplication {
  name = "lock-hook";
  text = ''
    current_ssid=$(${lib.getExe' pkgs.wirelesstools "iwgetid"} -r)
    home_ssid=$(cat "${config.sops.secrets.home_ssid.path}")

    [[ "$current_ssid" == "$home_ssid" ]] && exit 0

    STATE_DIR="/tmp/noctalia-lock-state"
    mkdir -p "$STATE_DIR"
    rm -f "$STATE_DIR/browser_open"

    if pgrep -x "$BROWSER" > /dev/null; then
      touch "$STATE_DIR/browser_open"
      pkill -x "$BROWSER" || true
    fi

    noctalia msg session lock && touch "$STATE_DIR/locked"
  '';
}
