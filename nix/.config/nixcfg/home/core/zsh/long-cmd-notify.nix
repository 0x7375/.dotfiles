{ pkgs, ... }:

{
  home.file.".config/zsh/longcmd-notify.zsh" = {
    force = true;
    mutable = true;
    text = # bash
      ''
        time_threshold=10
        time_taken=0
        cmd=""
        start_window_id=""

        long_command_alert_start() {
          time_taken=$(${pkgs.coreutils}/bin/date +%s)
          cmd="$1"
          start_window_id=$(${pkgs.xdotool}/bin/xdotool getactivewindow)
        }

        long_command_alert_end() {
          if [[ $time_taken -gt 0 ]]; then
            local duration=$(($(${pkgs.coreutils}/bin/date +%s) - $time_taken))
            if [[ $duration -gt $time_threshold ]]; then
              if ! original_window_is_focused; then
                ${pkgs.libnotify}/bin/notify-send "Command took $duration seconds" "$cmd"
              fi
            fi
            time_taken=0
          fi
        }

        original_window_is_focused() {
          local current_window_id=$(${pkgs.xdotool}/bin/xdotool getactivewindow)
          [[ "$current_window_id" == "$start_window_id" ]]
        }

        autoload -U add-zsh-hook
        add-zsh-hook preexec long_command_alert_start
        add-zsh-hook precmd long_command_alert_end
      '';
  };
}
