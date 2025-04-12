{
  myLib,
  config,
  lib,
  ...
}:

{
  options.me = {
    flakeDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/${config.me.user}/.dotfiles/nix/.config/nixcfg";
      description = "Path to the nixos flake directory";
    };

    dotfilesDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/${config.me.user}/.dotfiles";
      description = "Path to the dotfiles directory";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "ayko";
      description = "User name";
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

    allowedIPsRootLogin = lib.mkOption {
      type = lib.types.str;
      default = "${myLib.network.lan.addr.desktop}";
      description = "IP address(es) allowed to login as root";
    };

    publicKey = lib.mkOption {
      type = lib.types.str;
      default = myLib.ssh-keys.${config.me.hostname} or "";
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
        default = (!config.me.boot.debug.enable && config.me.boot.enable);
        description = "Enable silent boot";
      };
      debug.enable = lib.mkEnableOption "Make boot verbose";
    };

    btrfs.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable autoscrub and automatic home snapshots";
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

    capsLockRemap.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Remap caps lock to control/esc using interception-tools";
    };

    keyd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Remap keys using keyd and keyd-application-mapper";
    };

    devPkgs.enable = lib.mkEnableOption "Install development packages";
    minecraft.enable = lib.mkEnableOption "Create minecraft server";

    syncthing.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.me.syncthing-client.enable;
      description = "Setup syncthing";
    };

    syncthing-client.enable = lib.mkEnableOption "Enable syncthing client and setup directories";

    gui = {
      enable = lib.mkEnableOption "Enable graphical config";

      bundles = {
        gaming.enable = lib.mkEnableOption "Install steam and other game launchers";
        postgresql.enable = lib.mkEnableOption "Run a postgresql server";
        virtualBox.enable = lib.mkEnableOption "Enable virtual box";
        neo4j.enable = lib.mkEnableOption "Run a neo4j server";
        gns3.enable = lib.mkEnableOption "Run gns3 server";
      };
    };
  };
}
