{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "change-volume";
  runtimeInputs = with pkgs; [
    pamixer
    libnotify
  ];
  text = ''
    send_notification() {
        local -ri volume=$(pamixer --get-volume)

        local icon
        if [[ $volume -gt 70 ]]; then
            icon="high"
        elif [[ $volume -gt 40 ]]; then
            icon="medium"
        else
            icon="low"
        fi

        notify-send -a "volume" -t 2000 -r 9993 -u low -i "volume-$icon" -h int:value:"$volume" "Volume" "Currently at ''${volume}%"
    }

    send_muted() {
        notify-send -a "volume" -t 2000 -r 9993 -u low -i "volume-mute" "Muted"
    }

    case $1 in
    up)
        pamixer -i 5
        send_notification
        ;;
    down)
        pamixer -d 5
        send_notification
        ;;
    mute)
        pamixer -t
        if [[ $(pamixer --get-mute) == "true" ]]; then
            send_muted
        else
            send_notification
        fi
        ;;
    esac
  '';
}
