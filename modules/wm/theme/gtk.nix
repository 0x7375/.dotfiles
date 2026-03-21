{
  lib,
  config,
  pkgs,
  mkNixos,
  ...
}:

# gtk theme and icon theme need to be symlinked to work, I symlink and swap inside swap-theme
let
  pascalCase =
    string:
    let
      firstLetter = lib.toUpper (lib.substring 0 1 string);
      rest = lib.toLower (lib.substring 1 (lib.stringLength string - 1) string);
    in
    firstLetter + rest;

  inherit (config.me.wm)
    theme
    cursorTheme
    iconTheme
    font
    ;

  fontNameAndSize = font.family + " 11";

  cssContent = # css
    { colorScheme, version }:
    ''
      @import url("file://${theme.package}/share/themes/${theme.name}-${pascalCase colorScheme}/gtk-${version}.0/gtk.css");

      # window.csd {
      #   border-radius: 0;
      # }

      window.solid-csd,
      window.solid-csd.maximized,
      window.solid-csd.fullscreen {
        padding: 0px;
        border: none;
        box-shadow: none;
      }
    '';
in
{
  options.me.wm =
    let
      inherit (lib) types mkOption;

      mkThemeOption =
        {
          name,
          package,
        }:
        {
          name = mkOption {
            type = types.str;
            default = name;
          };

          package = mkOption {
            type = types.package;
            default = package;
          };
        };

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
      theme = mkThemeOption {
        name = "Gruvbox";
        package = pkgs.gruvbox-gtk-theme.override {
          colorVariants = [
            "dark"
            "light"
          ];
        };
      };

      iconTheme = mkThemeOption {
        name = "Gruvbox-Plus";
        package = pkgs.auto.gruvbox-plus-icons;
      };

      cursorTheme =
        mkThemeOption {
          name = "Bibata-Modern-Ice";
          package = pkgs.bibata-cursors;
        }
        // {
          size = mkOption {
            type = types.int;
            default = 24;
          };
        };

      font = mkFontOption {
        family = "Lexend";
        package = pkgs.lexend;
        size = 11;
      };

      terminalFont = mkFontOption {
        family = "0xproto Nerd Font";
        size = 18;
        package = pkgs.nerd-fonts._0xproto;
      };
    };

  config = lib.mkIf config.me.wm.enable (mkNixos {
    nixpkgs.overlays = [
      (final: prev: {
        gruvbox-gtk-theme = final.unstable.gruvbox-gtk-theme;
      })
    ];

    programs.dconf.enable = true;

    vars = {
      GTK_THEME = theme.name;
      GTK2_RC_FILES = "${config.me.home}/.config/gtk-2.0/gtkrc";
    };

    programs.dconf.profiles = {
      user.databases = [
        {
          settings = {
            "org/gtk/settings/file-chooser" = {
              show-hidden = true;
              sort-directories-first = true;
            };
            "org/gnome/desktop/interface" = {
              "font-name" = fontNameAndSize;
              "gtk-theme" = theme.name;
              "icon-theme" = iconTheme.name;
              "cursor-theme" = cursorTheme.name;
              "cursor-size" = lib.gvariant.mkUint16 cursorTheme.size;
            };
          };
        }
      ];
    };

    hj.xdg.data.files."icons/default/index.theme".text = # toml
      ''
        [Icon Theme]
        Inherits = ${cursorTheme.name}
      '';

    packages = with pkgs; [
      gtk3
      font.package
      iconTheme.package
      cursorTheme.package
      theme.package
    ];

    hj.xdg.config.files = {
      "gtk-2.0/gtkrc".text = ''
        gtk-cursor-theme-name = "${cursorTheme.name}"
        gtk-cursor-theme-size = ${toString cursorTheme.size}
        gtk-font-name = "${fontNameAndSize}"
        gtk-icon-theme-name = "${iconTheme.name}"
        gtk-theme-name = "${theme.name}"
        gtk-enable-primary-paste = false
        gtk-decoration-layout =

      '';
      "gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-recent-files-enabled=false
        gtk-cursor-theme-name=${cursorTheme.name}
        gtk-cursor-theme-size=${toString cursorTheme.size}
        gtk-font-name=${fontNameAndSize}
        gtk-icon-theme-name=${iconTheme.name}
        gtk-theme-name=${theme.name}
        gtk-enable-primary-paste=false
        gtk-decoration-layout=
      '';
      "gtk-3.0/bookmarks".text = ''
        file://${config.me.home}/.config
        file://${config.me.home}/uni
        file://${config.me.home}/repos
      '';
      "gtk-4.0/settings.ini".source = config.hj.xdg.config.files."gtk-3.0/settings.ini".source;

    };

    tinted.files = {
      ".config/gtk-3.0/gtk.css".text =
        palette:
        cssContent {
          colorScheme = palette._theme;
          version = "3";
        };
      ".config/gtk-4.0/gtk.css".text =
        palette:
        cssContent {
          colorScheme = palette._theme;
          version = "4";
        };
    };
  });
}
