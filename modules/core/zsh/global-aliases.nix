{ config, ... }:

{
  hj.xdg.config.files."zsh/global-aliases.zsh".text = # bash
    ''
      alias -g @nout="> /dev/null"
      alias -g @nerr="2> /dev/null"
      alias -g @null="> /dev/null 2>&1"
      alias -g @d="@null & disown"

      _smart_copy() {
        local data=$(cat)
        if [[ -n "$SSH_TTY" ]]; then
          printf '\033]52;c;%s\a' "$(printf '%s' "$data" | base64 | tr -d '\n')" > "$SSH_TTY"
        else
          printf '%s' "$data" | ${config.me.wm.copy}
        fi
      }

      alias -g @copy="| _smart_copy"
    '';
}
