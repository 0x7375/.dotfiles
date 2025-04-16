{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "tmux-sessionizer";
  runtimeInputs = with pkgs; [
    procps
    tmux
    coreutils-full
    fzf
    gnused
  ];
  text = ''
    dirs=(~/ ~/.config ~/uni ~/perso ~/repos)

    mkdir -p "''${dirs[@]}"

    if [[ $# -eq 1 ]]; then
      selected="$1"
    else
      selected=$(find -L "''${dirs[@]}" \
        -maxdepth 1 -mindepth 1 -type d ! -name '.stfolder' ! -name '.stversions' \
        | sed "s|^$HOME|~|" \
        | fzf --reverse)
      selected=''${selected/\~/$HOME}
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
