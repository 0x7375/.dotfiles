{
  myLib,
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (config.gtk) gtk4;
  pascal =
    string:
    let
      firstLetter = lib.toUpper (lib.substring 0 1 string);
      rest = lib.toLower (lib.substring 1 (lib.stringLength string - 1) string);
    in
    firstLetter + rest;

  cssContent = # css
    theme: ''
      @import url("file://${gtk4.theme.package}/share/themes/${gtk4.theme.name}${
        if theme != null then "-" + (pascal theme) else ""
      }/gtk-4.0/gtk.css");

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
lib.mkIf config.me.gui.enable {
  # home.file.".local/share/icons/Gruvbox-Plus-Dark".source =
  #   "${pkgs.gruvbox-plus-icons}/share/icons/Gruvbox-Plus-Dark";

  home.sessionVariables = {
    GTK_THEME = config.gtk.theme.name;
  };

  gtk = rec {
    enable = true;
    font = {
      name = "Ubuntu Nerd Font";
      package = pkgs.nerd-fonts.ubuntu;
      size = 11;
    };
    iconTheme = {
      # package = (
      #   pkgs.gruvbox-plus-icons.override {
      #     folder-color = "grey";
      #   }
      # );
      # name = "Gruvbox-Plus";
      package = (
        pkgs.colloid-icon-theme.override {
          colorVariants = [ "grey" ];
        }
      );
      name = "Colloid-Grey";
    };
    theme = {
      package = (
        pkgs.colloid-gtk-theme.override {
          themeVariants = [ "grey" ];
          tweaks = [
            "black"
            "rimless"
          ];
        }
      );
      name = "Colloid-Grey";
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = config.me.cursorSize;
    };
    gtk3.extraConfig = {
      # gtk-application-prefer-dark-theme = 1;
      gtk-enable-primary-paste = false;
      gtk-decoration-layout = "";
      gtk-recent-files-enabled = false;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk2.extraConfig = ''
      # gtk-application-prefer-dark-theme = "1"
      gtk-enable-primary-paste = false
      gtk-decoration-layout =
    '';
    gtk4.extraConfig = gtk3.extraConfig;
    gtk3.extraCss = cssContent null;
  };

  dconf.settings = {
    # "org/gnome/desktop/interface" = {
    #   color-scheme = "prefer-dark";
    # };
    "org/gtk/settings/file-chooser" = {
      show-hidden = true;
      sort-directories-first = true;
    };
  };

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file:///home/${config.me.user}/.config
    file:///home/${config.me.user}/uni
    file:///home/${config.me.user}/repos
  '';

  xdg.dataFile."icons/default/index.theme".text = # toml
    ''
      [Icon Theme]
      Inherits = ${config.gtk.cursorTheme.name}
    '';

  home.packages = [ pkgs.gtk3 ];

  xdg.configFile."gtk-4.0/gtk.css".enable = lib.mkForce false;

  xdg.configFile."gtk-4.0/dark.css".text = cssContent "dark";
  xdg.configFile."gtk-4.0/light.css".text = cssContent "light";

  systemd.user.tmpfiles.rules =
    let
      gtk = "/home/${config.me.user}/.config/gtk-4.0";
    in
    [
      "L ${gtk}/gtk.css - - - - ${gtk}/dark.css"
    ];
}
