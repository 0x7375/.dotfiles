{
  myLib,
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (myLib) palette;
  cssContent = # css
    ''
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
      # name = "Gruvbox-Plus-Dark";
      package = (
        pkgs.colloid-icon-theme.override {
          colorVariants = [ "grey" ];
        }
      );
      name = "Colloid-Grey-Dark";
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
      name = "Colloid-Grey-Dark";
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = config.me.cursorSize;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-enable-primary-paste = false;
      gtk-decoration-layout = "";
      gtk-recent-files-enabled = false;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme = "1"
      gtk-enable-primary-paste = false
      gtk-decoration-layout =
    '';
    gtk4.extraConfig = gtk3.extraConfig;

    gtk3.extraCss = cssContent;
    gtk4.extraCss = gtk3.extraCss;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
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
}
