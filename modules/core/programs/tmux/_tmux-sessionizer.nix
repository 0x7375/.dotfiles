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
  ];
  text = ''
    dirs=(
      ".config"
      ".config/nixcfg"
      "uni"
      "perso"
      "repos"
    )

    mkdir -p "''${dirs[@]/#/$HOME/}"

    if [[ $# -eq 1 ]]; then
      selected="$1"
    else
      selected=$(fd -L . "$HOME" "''${dirs[@]/#/$HOME/}" \
        --max-depth 1 --min-depth 1 --type d --hidden --exclude '*.st*' \
        | sed "s|^$HOME/||" \
        | fzf)
      selected=$HOME/''${selected}
    fi

    [[ -z $selected ]] && exit 0

    selected_name="$(basename "$selected" | tr . _)"

    if tmux has-session -t="$selected_name" 2>/dev/null; then
      if [[ -z ''${TMUX:-} ]]; then
        exec tmux attach-session -t "$selected_name"
      else
        exec tmux switch-client -t "$selected_name"
      fi
    else
      if [[ -z ''${TMUX:-} ]]; then
        exec tmux new-session -s "$selected_name" -c "$selected"
      else
        tmux new-session -ds "$selected_name" -c "$selected"
        exec tmux switch-client -t "$selected_name"
      fi
    fi
  '';
}
