pkgs:
pkgs.writeShellApplication {
  name = "tmux-jump";
  bashOptions = [ ];
  runtimeInputs = with pkgs; [
    gawk
    coreutils-full
    xdg-utils
  ];
  text = ''
    raw_loc="$(cat)"

    tmux delete-buffer 2>/dev/null || true
    tmux save-buffer - 2>/dev/null | tmux load-buffer -w - 2>/dev/null || true

    loc="''${raw_loc//[<>]/}"

    if [[ "$loc" =~ ^https?:// ]]; then
      xdg-open "$loc" >/dev/null 2>&1 &
      exit 0
    fi

    file="''${loc%%:*}"
    [ -f "$file" ] || exit 0

    rest="''${loc#*:}"
    line="''${rest%%:*}"
    col="''${rest#*:}"
    [ "$col" = "$rest" ] && col=1

    line="''${line//[^0-9]/}"
    col="''${col//[^0-9]/}"
    [ -z "$line" ] && line=1
    [ -z "$col" ] && col=1

    session=$(tmux display-message -p '#S')
    sock="/tmp/nvim-$session.sock"

    expr="execute(\"edit \" . fnameescape(\"$file\")) . execute(\"call cursor($line,$col)\")"
    nvim --server "$sock" --remote-expr "$expr" >/dev/null

    target=$(tmux list-windows -t "$session" -F '#{window_index}:#{window_name}' \
      | awk -F: '$2=="nvim"{print $1; exit}')
    [ -z "$target" ] && target=$(tmux list-windows -t "$session" -F '#{window_index}' | head -1)

    tmux select-window -t "$session:$target"
  '';
}
