{
  myLib,
  config,
  lib,
  ...
}:

let
  cfg = config.me;
in
{
  config = {
    assertions = [
      {
        assertion = cfg.gui.displayServer == null || cfg.gui.enable;
        message = "Display server '${cfg.gui.displayServer}' requires gui.enable to be true";
      }
    ];
  };

  options.me = {
    flakeDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/${cfg.user}/.config/nixcfg";
      description = "Path to the nixos flake directory";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "ayko";
      description = "User name";
    };

    browser = lib.mkOption {
      type = lib.types.str;
      default = "zen-beta";
      description = "Default browser";
    };

    uid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "User id";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "hostname";
      description = "System hostname";
    };

    publicKey = lib.mkOption {
      type = lib.types.str;
      default = myLib.ssh-keys.${cfg.hostname} or "";
      description = "Public key used for commit signing";
    };

    cursorSize = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Cursor size";
    };

    refreshRate = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "Refresh rate (used to choose the right config for firefox)";
    };

    boot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Setup systemd boot with plymouth";
      };
      silent.enable = lib.mkOption {
        type = lib.types.bool;
        default = (!cfg.boot.debug.enable && cfg.boot.enable);
        description = "Enable silent boot";
      };
      debug.enable = lib.mkEnableOption "Make boot verbose";
    };

    network.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use nextdns and create NetworkManager profiles";
    };

    secrets.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Deploy secrets using sops-nix";
    };

    keyd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Remap keys using keyd and keyd-application-mapper";
    };

    syncthing.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.syncthing-client.enable;
      description = "Setup syncthing";
    };
    syncthing-client.enable = lib.mkEnableOption "Enable syncthing client and setup directories";

    devPkgs.enable = lib.mkEnableOption "Install development packages";
    minecraft.enable = lib.mkEnableOption "Create minecraft server";
    capsLockRemap.enable = lib.mkEnableOption "Remap caps lock to control/esc using interception-tools";
    btrfs.enable = lib.mkEnableOption "Enable autoscrub and automatic home snapshots";

    gui = {
      enable = lib.mkEnableOption "Enable graphical config";

      displayServer = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "xorg"
            "wayland"
          ]
        );
        default = if cfg.gui.enable then "xorg" else null;
        description = "Display server to use";
      };

      terminal = lib.mkOption {
        type = lib.types.str;
        default = if cfg.gui.displayServer == "xorg" then "alacritty" else "foot";
        description = "Default terminal emulator (needs to be valid pkg aswell)";
      };

      fontSize = lib.mkOption {
        type = lib.types.int;
        default = 16;
        description = "Font size for terminal";
      };

      bundles = {
        gaming.enable = lib.mkEnableOption "Install steam and other game launchers";
        postgresql.enable = lib.mkEnableOption "Run a postgresql server";
        virtualBox.enable = lib.mkEnableOption "Enable virtual box";
        neo4j.enable = lib.mkEnableOption "Run a neo4j server";
      };
    };
  };
}
