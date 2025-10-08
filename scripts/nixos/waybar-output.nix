{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "waybar-output";
  runtimeInputs = with pkgs; [
    waybar
    hyprland
    systemd
    gnugrep
  ];
  text = # bash
    ''
      OUTPUT_FILE="$HOME/.config/waybar/output.json"

      if hyprctl monitors | grep -q "HDMI-A-2"; then
        echo '{"output": "HDMI-A-2"}' > "$OUTPUT_FILE"
      elif hyprctl monitors | grep -q "HDMI-A-1"; then
        echo '{"output": "HDMI-A-1"}' > "$OUTPUT_FILE"
      else
        echo '{"output": "eDP-1"}' > "$OUTPUT_FILE"
      fi

      if systemctl --user is-active --quiet waybar; then
        systemctl --user restart waybar
      fi
    '';
}
