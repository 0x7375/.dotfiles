{
  flake.nixos.desktop =
    {
      pkgs,
      inputs,
      lib,
      ...
    }:
    let
      extensions =
        with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system};
        [
          bluetooth
          nix
          wifi-commander
        ]
        ++ (with inputs.vicinae.packages.x86_64-linux; [
          (mkRayCastExtension {
            name = "gif-search";
            sha256 = "sha256-G7il8T1L+P/2mXWJsb68n4BCbVKcrrtK8GnBNxzt73Q=";
            rev = "4d417c2dfd86a5b2bea202d4a7b48d8eb3dbaeb1";
          })
        ]);
    in
    {
      packages = [ pkgs.vicinae ];

      me.desktop.startup = {
        autocutsel = "${lib.getExe pkgs.autocutsel} -fork";
        vicinae = "${lib.getExe pkgs.vicinae} server";
      };

      hj.files =
        builtins.listToAttrs (
          map (ext: {
            name = ".local/share/vicinae/extensions/${ext.name}";
            value.source = ext;
          }) extensions
        )
        // {
          ".config/vicinae/vicinae.json" = {
            generator = lib.generators.toJSON { };
            value = {
              closeOnFocusLoss = true;
              theme.name = "gruvbox";
              window = {
                csd = false;
                opacity = 1;
                rounding = 0;
                dim_around = false;
                blur.enabled = false;
              };
              providers = {
                "vicinae/about".enabled = false;
              };
            };
          };
        };

      tinted.files.".local/share/vicinae/themes/gruvbox.toml".text =
        p:
        # ini
        ''
          [meta]
          version = 1
          name = "Gruvbox"
          description = "Designed as a theme with pastel 'retro groove' colors"
          variant = "${p._theme}"

          [colors.core]
          background = "${p.bg0_dark}"
          foreground = "${p.fg1}"
          secondary_background = "${p.bg0}"
          border = "${p.bg2}"
          accent = "${p.bg1}"

          [colors.accents]
          blue = "${p.blue}"
          green = "${p.green}"
          magenta = "${p.magenta}"
          orange = "${p.orange}"
          purple = "${p.magenta}"
          red = "${p.red}"
          yellow = "${p.yellow}"
          cyan = "${p.cyan}"

          [colors.list.item.selection]
          background = "${p.bg1}"
          secondary_background = "${p.bg1}"

          [colors.grid.item]
          background = "${p.bg1}"
        '';
    };
}
