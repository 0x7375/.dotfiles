{
  config,
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "lock";
  bashOptions = [ ];
  runtimeInputs = with pkgs; [
    procps
    hyprlock
    hyprland
  ];
  text =
    let
      inherit (config.me.wm) browser;
    in
    # bash
    ''
      if pidof hyprlock > /dev/null; then
        exit 0
      fi

      browser_was_open=false
      pgrep -x ${browser} > /dev/null && browser_was_open=true
      pkill -x ${browser} || true

      ( sleep 300 && systemctl hibernate ) &
      HIBERNATE_PID=$!

      if grep -q "closed" /proc/acpi/button/lid/*/state 2> /dev/null; then
        systemctl hibernate
      fi
        
      hyprlock

      kill "$HIBERNATE_PID" 2>/dev/null || true
      $browser_was_open && hyprctl dispatch exec -- ${browser}
    '';
}
