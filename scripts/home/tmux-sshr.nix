{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "tmux-sshr";
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
      
      selected=$(echo "$hosts" | fzf --reverse --border)
    fi

    [[ -z $selected ]] && exit 0

    printf "Enter username (default: %s): " "$USER"
    read -r username
    username=''${username:-$USER}

    ssh -t "$username@$selected" "
      if command -v tmux &> /dev/null; then
        if tmux has-session &> /dev/null; then
          exec tmux attach-session
        else
          exec tmux new-session -s \"ssh-$username@$selected\"
        fi
      else
        exec \$SHELL
      fi
    "
  '';
}
