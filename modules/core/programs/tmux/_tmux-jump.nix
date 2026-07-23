pkgs:
pkgs.writeShellApplication {
  name = "tmux-jump";
  bashOptions = [ ];
  runtimeInputs = with pkgs; [
    gawk
    coreutils-full
  ];
  text = ''
    loc="$(cat)"
    file="''${loc%%:*}"
    rest="''${loc#*:}"
    line="''${rest%%:*}"
    col="''${rest#*:}"
    [ "$col" = "$rest" ] && col=1

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
