{
  flake.shared.core =
    {
      lib,
      config,
      ...
    }:
    let
      inherit (config.me) home;
    in
    {
      config = {
        nixpkgs.overlays = [
          (final: prev: {
            my = (prev.my or { }) // {
              swap-theme = import ./_swap-theme.nix {
                inherit lib config;
                pkgs = final;
              };
            };
          })
        ];

        vars.TINTED_FILE = "${home}/${config.tinted.stateDir}/theme";

        tinted = {
          enable = true;
          inherit (config.me) user;
          homeDir = config.me.home;

          palette = {
            _theme = {
              dark = "dark";
              light = "light";
            };
            bg0_dark = {
              dark = "#1d2021";
              light = "#f2e5bc";
            };
            bg0 = {
              dark = "#282828";
              light = "#fbf1c7";
            };
            bg1 = {
              dark = "#3c3836";
              light = "#ebdbb2";
            };
            bg2 = {
              dark = "#504945";
              light = "#d5c4a1";
            };
            bg3 = {
              dark = "#665c54";
              light = "#bdae93";
            };
            fg4 = {
              dark = "#a89984";
              light = "#7c6f64";
            };
            fg3 = {
              dark = "#bdae93";
              light = "#665c54";
            };
            fg2 = {
              dark = "#d5c4a1";
              light = "#504945";
            };
            fg1 = {
              dark = "#ebdbb2";
              light = "#3c3836";
            };
            fg0 = {
              dark = "#fbf1c7";
              light = "#282828";
            };
            red = {
              dark = "#fb4934";
              light = "#9d0006";
            };
            green = {
              dark = "#b8bb26";
              light = "#b57614";
            };
            yellow = {
              dark = "#fabd2f";
              light = "#79740e";
            };
            cyan = {
              dark = "#8ec07c";
              light = "#427b58";
            };
            blue = {
              dark = "#83a598";
              light = "#076678";
            };
            magenta = {
              dark = "#d3869b";
              light = "#8f3f71";
            };
            orange = {
              dark = "#fe8019";
              light = "#af3a03";
            };
          };

          files."${config.tinted.stateDir}/palette" = {
            stripHash = true;
            generator = lib.generators.toKeyValue { };
          };
        };
      };
    };
}
