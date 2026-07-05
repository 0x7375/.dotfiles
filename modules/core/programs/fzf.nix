{
  flake.modules.generic.core =
    { lib, pkgs, ... }:
    {
      packages = [ pkgs.fzf ];
      vars.FZF_DEFAULT_OPTS =
        let
          buildColors =
            colors: lib.concatStringsSep "," (lib.mapAttrsToList (k: v: "${k}:${toString v}") colors);
        in
        lib.cli.toCommandLineShellGNU { } {
          color = buildColors {
            "bg+" = 0;
            bg = -1;
            spinner = 6;
            hl = 4;
            fg = 7;
            header = 4;
            info = 3;
            pointer = 6;
            marker = 6;
            "fg+" = -1;
            prompt = 3;
            "hl+" = 4;
            border = 0;
            "preview-border" = 0;
          };

          info-command = "printf '%s/%s' \"\\$FZF_POS\" \"\\$FZF_MATCH_COUNT\"";
          pointer = " >";
          prompt = " ";
          no-scrollbar = true;
          gutter = " ";
          info = "inline-right";
          separator = "─";
          reverse = true;
        };
    };
}
