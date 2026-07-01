{
  flake.modules.generic.core =
    { pkgs, ... }:
    {
      packages = [ pkgs.fzf ];
      vars.FZF_DEFAULT_OPTS = "--color=bg+:0,bg:-1,spinner:6,hl:4,fg:7,header:4,info:3,pointer:6,marker:6,fg+:-1,prompt:3,hl+:4,border:0,preview-border:0 --pointer='>' --scrollbar=' ' --separator=' ' --gutter=' ' --info=inline-right --no-separator";
    };
}
