{
  hj.xdg.config.files."zsh/global-aliases.zsh".text = # bash
    ''
      alias -g @nout="> /dev/null"
      alias -g @nerr="2> /dev/null"
      alias -g @null="> /dev/null 2>&1"
      alias -g @d="@null & disown"
      alias -g @copy="| xclip -sel clip"
    '';
}
