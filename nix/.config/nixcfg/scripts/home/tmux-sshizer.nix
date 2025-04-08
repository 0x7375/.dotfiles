{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "tmux-sshizer";
  runtimeInputs = with pkgs; [
    openssh
    fzf
    gnused
    coreutils-full
  ];
  text = ''
    if [[ $# -eq 1 ]]; then
      selected="$1"
    else
      hosts="$(cut -d' ' -f1 < ~/.ssh/known_hosts 2>/dev/null | sed 's/,/ /g' | tr ' ' '\n' | sort -u)"
      
      selected=$(echo "$hosts" | fzf --reverse)
    fi

    [[ -z "$selected" ]] && exit 0

    ssh -t "$selected" "
      if command -v tmux >/dev/null 2>&1; then
        if tmux has-session 2>/dev/null; then
          exec tmux attach-session
        else
          exec tmux new-session -s \"$(whoami)-$(hostname)\"
        fi
      else
        exec \$SHELL
      fi
    "
  '';
}
