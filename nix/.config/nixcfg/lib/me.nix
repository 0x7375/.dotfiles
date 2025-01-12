{ config, lib, ... }:

{
  options.me = {
    flakeDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/${config.me.user}/.config/nixcfg";
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

    gitPublicKey = lib.mkOption {
      type = lib.types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJahc82zjVv6+UDKi3eN9oZRfGRE7zhBivo5TYtDLe53";
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
      description = "Refresh rate used for smoothfox firefox config";
    };

    boot.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use systemd with silent boot config";
    };

    network.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use nextdns and create NetworkManager profiles";
    };

    secrets.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use agenix secrets";
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
      };
    };
  };
}
