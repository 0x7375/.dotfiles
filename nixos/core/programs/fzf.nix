{ pkgs, ... }:

{
  packages = [ pkgs.fzf ];

  vars.FZF_DEFAULT_OPTS = "--color=bw,border:0,preview-border:0 --pointer='>' --scrollbar=' ' --separator=' '";
}
