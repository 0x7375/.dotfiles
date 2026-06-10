{ pkgs }:
pkgs.writeShellApplication {
  name = "unlock-hook";
  text = ''
    STATE_DIR="/tmp/noctalia-lock-state"

    rm -f "$STATE_DIR/locked" || true

    if [[ -f "$STATE_DIR/browser_open" ]]; then
      "$BROWSER" &
      rm "$STATE_DIR/browser_open"
    fi
  '';
}
