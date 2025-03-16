{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "change-brightness";
  runtimeInputs = with pkgs; [
    brillo
    ddcutil
  ];
  text = ''
    fade=150000

    get_brightness() {
      local device="dev:$1"
      ddccontrol -r 0x10 "$device" 2>/dev/null | grep "Control 0x10:" | cut -d'/' -f2
    }

    set_brightness() {
      local device="dev:$1"
      local value=$2
      ddccontrol -r 0x10 -w "$value" "$device" >/dev/null 2>&1
    }

    for device in "/dev/i2c-2" "/dev/i2c-4"; do
      current=$(get_brightness "$device")
      case $1 in
      up)
          current=$(("$current" + 10))
          [ $current -gt 100 ] && current=100
          ;;
      down)
          current=$(("$current" - 10))
          [ $current -lt 0 ] && current=0
          ;;
      esac
      set_brightness "$device" "$current" &
    done

    case $1 in
    up)
        brillo -u $fade -q -A 10
        ;;
    down)
        brillo -u $fade -q -U 10
        ;;
    esac
  '';
}
