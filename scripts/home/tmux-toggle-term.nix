{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "tmux-toggle-term";
  runtimeInputs = with pkgs; [ tmux ];
  text = ''
    set -uo pipefail
    current_session="$(tmux display-message -p -F "#{session_name}" 2>/dev/null || echo "")"

    if [[ $current_session =~ -popup$ ]]; then
      tmux detach-client
    else
      popup_session="''${current_session}-popup"
      tmux popup -d '#{pane_current_path}' -xC -yC -w 100% -h 100% -E "tmux attach -t $popup_session || tmux new -s $popup_session"
      tmux set-hook -g session-closed "if-shell -b '[[ #{session_name} == $popup_session ]]' 'kill-session -t popup'"
    fi
  '';
}
