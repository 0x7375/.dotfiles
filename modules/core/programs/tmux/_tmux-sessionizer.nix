pkgs:
pkgs.writeShellApplication {
  name = "tmux-sessionizer";
  runtimeInputs = with pkgs; [
    procps
    tmux
    coreutils-full
    findutils
    fzf
    gnused
    gawk
  ];
  text = ''
    dirs=(
      ".config"
      "uni"
      "perso"
      "repos"
    )

    mkdir -p "''${dirs[@]/#/$HOME/}"

    if [[ $# -eq 1 ]]; then
      selected="$1"
    else
      selected=$(fd -L . "$HOME" "''${dirs[@]/#/$HOME/}" \
        --max-depth 1 --min-depth 1 --type d --hidden --exclude '*.st*' --format {} \
        | sed "s|^$HOME/||" \
        | fzf)
      selected=$HOME/''${selected}
    fi

    [[ -z $selected ]] && exit 0

    selected_name="$(basename "$selected" | tr . _)"

    # small disk usage banner on first session
    start_cmd=()
    if [[ "$selected" == "$HOME" ]]; then
      pct=$(df -h / | awk 'NR==2 {print $5}')
      pct_num=''${pct%\%}
      color='\e[1;97m'
      symbol='*'
      if (( pct_num >= 90 )); then
        color='\e[1;31m'
        symbol='!'
      fi
      start_cmd=(bash -c "clear; echo -e \"''${color}''${symbol} Root disk usage: ''${pct}\e[0m\"; exec \$SHELL")
    fi

    if tmux has-session -t="$selected_name" 2>/dev/null; then
      if [[ -z ''${TMUX:-} ]]; then
        exec tmux attach-session -t "$selected_name"
      else
        exec tmux switch-client -t "$selected_name"
      fi
    else
      if [[ -z ''${TMUX:-} ]]; then
        exec tmux new-session -s "$selected_name" -c "$selected" "''${start_cmd[@]}"
      else
        tmux new-session -ds "$selected_name" -c "$selected"
        exec tmux switch-client -t "$selected_name"
      fi
    fi
  '';
}
