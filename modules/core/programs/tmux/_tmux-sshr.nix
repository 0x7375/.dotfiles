pkgs:
pkgs.writeShellApplication {
  name = "tmux-sshr";
  runtimeInputs = with pkgs; [
    my.noctalia
    openssh
    fzf
    gnused
    coreutils-full
  ];
  text = ''
    if [[ $# -eq 1 ]]; then
      selected="$1"
    else
      selected=$(cut -d' ' -f1 < ~/.ssh/known_hosts 2>/dev/null | sed 's/,/ /g' | tr ' ' '\n' | sort -ur | noctalia dmenu -g world -p "Connect to...")
    fi

    [[ -z $selected ]] && exit 0

    username=$(awk -F: -v u="$USER" 'BEGIN {print u} ($3 == 0 || ($3 >= 1000 && $3 < 30000)) && $1 != u {print $1}' /etc/passwd | noctalia dmenu -g user -p "Username...")

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
