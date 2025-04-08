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
    };

    dotfilesDir = lib.mkOption {
      type = lib.types.str;
      default = "~/.dotfiles";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "ayko";
      description = "User name";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "hostname";
      description = "System hostname";
    };

    publicKey = lib.mkOption {
      type = lib.types.str;
      default = myLib.ssh-keys.${config.me.hostname};
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
      description = "Refresh rate used for smoothfox browser config";
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

    network.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use nextdns and create NetworkManager profiles";
    };

    secrets.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use secrets";
    };

    capsLockRemap.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Remap caps lock to control/esc using interception-tools";
    };

    keyd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Remap keys using keyd";
    };

    devPkgs.enable = lib.mkEnableOption "Install development packages";
    minecraft.enable = lib.mkEnableOption "Create minecraft server";

    syncthing.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.me.syncthing-client.enable;
      description = "Setup syncthing";
    };

    syncthing-client.enable = lib.mkEnableOption "Setup syncthing client";

    gui = {
      enable = lib.mkEnableOption "Enable graphical config";

      bundles = {
        gaming.enable = lib.mkEnableOption "Install steam and other game launchers";
        postgresql.enable = lib.mkEnableOption "Create a postgresql server";
        virtualBox.enable = lib.mkEnableOption "Enable virtual box";
        neo4j.enable = lib.mkEnableOption "Create a neo4j server";
        gns3.enable = lib.mkEnableOption "Start gns3 server";
      };
    };
  };
}
