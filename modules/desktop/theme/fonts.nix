{
  flake.shared.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.me.desktop =
        let
          inherit (lib) types mkOption;
          mkFontOption =
            {
              family,
              size,
              package,
            }:
            {
              family = mkOption {
                type = types.str;
                default = family;
              };

              size = mkOption {
                type = types.int;
                default = size;
              };

              package = mkOption {
                type = types.package;
                default = package;
              };
            };
        in
        {
          font = mkFontOption {
            family = "Lexend";
            package = pkgs.lexend;
            size = 11;
          };

          terminal.font = mkFontOption {
            family = "0xproto Nerd Font";
            size = 18;
            package = pkgs.nerd-fonts._0xproto;
          };
        };

      config = {
        nixpkgs.overlays = [
          (final: prev: {
            fonts = {
              CartographCF = final.callPackage ./_fonts/CartographCF.nix { };
              InconsolataNF = final.callPackage ./_fonts/InconsolataNF.nix { };
            };
          })
        ];

        fonts.packages =
          let
            inherit (config.me.desktop) font terminal;
          in
          [
            font.package
            terminal.font.package
          ];
      };
    };

  flake.nixos.desktop =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.me.desktop) terminal font;
    in
    {
      fonts = {
        fontconfig = {
          enable = true;
          defaultFonts = {
            monospace = [ terminal.font.family ];
            sansSerif = [ font.family ];
          };
        };

        packages = with pkgs; [
          font-awesome
          lexend
          nerd-fonts.terminess-ttf
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji

          # dunst
          fonts.CartographCF

          # waybar
          courier-prime
          nerd-fonts.mononoki
        ];
      };
    };
}
