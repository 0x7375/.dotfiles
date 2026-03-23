{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) getExe getExe';
in
lib.mkIf (config.me.wm.displayServer == "wayland") {
  hj.xdg.config.files."zsh/longcmd-notify.zsh" = {
    text =
      let
        activeWindow = "${getExe' pkgs.hyprland "hyprctl"} activewindow -j | ${getExe pkgs.jq} -r .address";
      in
      # bash
      ''
        [[ -z $WAYLAND_DISPLAY ]] && return 0

        time_threshold=10
        time_taken=0
        cmd=""
        start_window_id=""

        long_command_alert_start() {
          time_taken=$(${getExe' pkgs.coreutils "date"} +%s)
          cmd="$1"
          start_window_id=$(${activeWindow})
        }

        long_command_alert_end() {
          if [[ $time_taken -gt 0 ]]; then
            local duration=$(($(${getExe' pkgs.coreutils "date"} +%s) - $time_taken))
            if [[ $duration -gt $time_threshold ]]; then
              if ! original_window_is_focused; then
                duration=$(get_duration "$duration")
                ${getExe' pkgs.libnotify "notify-send"} -i "cli" "Command done: ''${duration}" "$cmd"
              fi
            fi
            time_taken=0
          fi
        }

        get_duration() {
          local duration=$1
          if [[ $duration -gt 3600 ]]; then
            duration=$((duration / 3600))
            minutes=$((duration % 60))
            duration="''${duration}h''${minutes:+''${minutes}m}"
          elif [[ $duration -ge 60 ]]; then
            duration=$((duration / 60))
            seconds=$((duration % 60))
            duration="''${duration}m''${seconds:+''${seconds}s}"
          else
            duration="''${duration}s"
          fi
          echo "$duration"
        }

        original_window_is_focused() {
          local current_window_id=$(${activeWindow})
          [[ $current_window_id == $start_window_id ]]
        }

        autoload -U add-zsh-hook
        add-zsh-hook preexec long_command_alert_start
        add-zsh-hook precmd long_command_alert_end
      '';
  };
}
