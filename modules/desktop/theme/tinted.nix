{
  flake.shared.desktop =
    {
      lib,
      config,
      ...
    }:
    let
      inherit (config.me) home;
      inherit (lib) types mkOption;
      cfg = config.me;
      path = home + "/.local/state/tinted/theme";
    in
    {
      options.me = {
        palette = mkOption {
          type = types.attrsOf (types.attrsOf types.str);
          default = {
            dark = {
              _theme = "dark";
              bg0_dark = "#1d2021";

              bg0 = "#282828";
              bg1 = "#3c3836";
              bg2 = "#504945";
              bg3 = "#665c54";
              fg4 = "#a89984";
              fg3 = "#bdae93";
              fg2 = "#d5c4a1";
              fg1 = "#ebdbb2";
              fg0 = "#fbf1c7";

              red = "#fb4934";
              green = "#b8bb26";
              yellow = "#fabd2f";
              cyan = "#8ec07c";
              blue = "#83a598";
              magenta = "#d3869b";
              orange = "#fe8019";
            };
            light = {
              _theme = "light";
              bg0_dark = "#f2e5bc";

              bg0 = "#fbf1c7";
              bg1 = "#ebdbb2";
              bg2 = "#d5c4a1";
              bg3 = "#bdae93";
              fg4 = "#7c6f64";
              fg3 = "#665c54";
              fg2 = "#504945";
              fg1 = "#3c3836";
              fg0 = "#282828";

              red = "#9d0006";
              yellow = "#b57614";
              green = "#79740e";
              cyan = "#427b58";
              blue = "#076678";
              magenta = "#8f3f71";
              orange = "#af3a03";
            };
          };
          internal = true;
        };

        hex = mkOption {
          type = types.attrsOf (types.attrsOf types.str);
          default =
            let
              map' = lib.mapAttrs (name: value: lib.removePrefix "#" value);
            in
            {
              dark = map' cfg.palette.dark;
              light = map' cfg.palette.light;
            };
          internal = true;
        };
      };

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

        tinted.enable = true;
        vars.TINTED_FILE = path;
      };
    };
}
