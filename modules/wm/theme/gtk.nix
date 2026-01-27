{
  lib,
  config,
  pkgs,
  mkNixos,
  ...
}:

let
  pascal =
    string:
    let
      firstLetter = lib.toUpper (lib.substring 0 1 string);
      rest = lib.toLower (lib.substring 1 (lib.stringLength string - 1) string);
    in
    firstLetter + rest;

  theme = {
    name = "Colloid-Grey";
    package = pkgs.colloid-gtk-theme.override {
      themeVariants = [ "grey" ];
      tweaks = [
        "black"
        "rimless"
      ];
    };
  };

  iconTheme = {
    name = theme.name;
    package = pkgs.colloid-icon-theme.override {
      colorVariants = [ "grey" ];
    };
  };
  cursorTheme = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
  };
  font = {
    name = "Ubuntu Nerd Font 11";
    package = pkgs.nerd-fonts.ubuntu;
  };

  cssContent = # css
    { colorScheme, version }:
    ''
      @import url("file://${theme.package}/share/themes/${theme.name}-${pascal colorScheme}/gtk-${version}.0/gtk.css");

      window.csd {
        border-radius: 0;
      }

      window.solid-csd,
      window.solid-csd.maximized,
      window.solid-csd.fullscreen {
        padding: 0px;
        border: none;
        box-shadow: none;
      }

      #NautilusPathButton {
          background-color: inherit;
      }
    '';
in
lib.mkIf config.me.wm.enable (mkNixos {
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
            "font-name" = font.name;
            "gtk-theme" = theme.name;
            "icon-theme" = iconTheme.name;
            "cursor-theme" = cursorTheme.name;
            "cursor-size" = lib.gvariant.mkUint16 config.me.cursorSize;
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
      gtk-cursor-theme-size = ${toString config.me.cursorSize}
      gtk-font-name = "${font.name}"
      gtk-icon-theme-name = "${iconTheme.name}"
      gtk-theme-name = "${theme.name}"
      gtk-enable-primary-paste = false
      gtk-decoration-layout =

    '';
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-recent-files-enabled=false
      gtk-cursor-theme-name=${cursorTheme.name}
      gtk-cursor-theme-size=${toString config.me.cursorSize}
      gtk-font-name=${font.name}
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
    ".config/gtk-3.0/gtk.css" = {
      text =
        palette:
        cssContent {
          colorScheme = palette._theme;
          version = "3";
        };
    };
    ".config/gtk-4.0/gtk.css" = {
      text =
        palette:
        cssContent {
          colorScheme = palette._theme;
          version = "4";
        };
    };
  };
})
