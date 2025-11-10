{
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
        assertion = cfg.desktop.displayServer == null || cfg.desktop.enable;
        message = "Display server '${cfg.desktop.displayServer}' requires desktop.enable to be true";
      }
    ];
  };

  options.me = {
    flakeDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/${cfg.user}/.config/nixcfg";
      description = "Path to the nixos flake directory";
    };

    home = lib.mkOption {
      type = lib.types.str;
      default = "/home/${cfg.user}";
      description = "Home directory";
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

    mediaGroup = lib.mkOption {
      type = lib.types.str;
      default = "media";
      description = "Media group name";
      internal = true;
    };

    barFontSize = lib.mkOption {
      type = lib.types.int;
      default = 13;
      description = "Top bar font size";
      internal = true;
    };

    sshKeys = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        yugen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJahc82zjVv6+UDKi3eN9oZRfGRE7zhBivo5TYtDLe53 yugen";
        ryusei = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH9wtfhfEPZ6GVA4FWRUk5KXtTttn6Q4qjxO1apMc7RK ryusei";
        kumo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcGpmfziJoYbPbfdZi/REVStrNgl+F8lwVf1t2oLdaZ kumo";
        hikari = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVezt2Z6LhXPzAMhn6nJ0zXbrWXd93+QKmBqJ+8uE+s hikari";
      };
      description = "SSH public keys";
      internal = true;
    };

    networkIps = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.attrsOf (lib.types.either lib.types.str (lib.types.attrsOf lib.types.str))
      );
      default = {
        lan = {
          subnet = "192.168.1.0/24";
          gateway = "192.168.1.254";
          addr = {
            server = "192.168.1.95";
            desktop = "192.168.1.120";
            laptop = "192.168.1.198";
          };
        };
        vpn = {
          subnet = "10.0.0.0/24";
          addr = {
            server = "10.0.0.1";
            laptop = "10.0.0.2";
            phone = "10.0.0.3";
          };
        };
      };
      internal = true;
    };

    palette = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      default = {
        dark = {
          _theme = "dark";
          bg0_dark = "#000000";

          bg0 = "#000000";
          bg1 = "#202020";
          bg2 = "#404040";
          bg3 = "#606060";
          fg4 = "#808080";
          fg3 = "#808080";
          fg2 = "#A0A0A0";
          fg1 = "#A0A0A0";
          fg0 = "#A0A0A0";

          red = "#d4726f";
          green = "#7eb882";
          yellow = "#606060";
          cyan = "#404040";
          blue = "#A0A0A0";
          magenta = "#808080";
          orange = "#606060";
        };
        light = {
          _theme = "light";
          bg0_dark = "#FFFFFF";

          bg0 = "#FFFFFF";
          bg1 = "#BFBFBF";
          bg2 = "#9F9F9F";
          bg3 = "#9F9F9F";
          fg4 = "#7F7F7F";
          fg3 = "#7F7F7F";
          fg2 = "#5F5F5F";
          fg1 = "#5F5F5F";
          fg0 = "#5F5F5F";

          red = "#a8423f";
          yellow = "#9F9F9F";
          green = "#4a7c4e";
          cyan = "#7F7F7F";
          blue = "#5F5F5F";
          magenta = "#7F7F7F";
          orange = "#9F9F9F";
        };
      };
      description = "Color palette";
      internal = true;
    };

    hex = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      default =
        let
          map = lib.mapAttrs (name: value: lib.removePrefix "#" value);
        in
        {
          dark = map cfg.palette.dark;
          light = map cfg.palette.light;
        };
      description = "Color palette in hex format (without #)";
      internal = true;
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "hostname";
      description = "System hostname";
    };

    publicKey = lib.mkOption {
      type = lib.types.str;
      default = cfg.sshKeys.${cfg.hostname} or "";
      description = "Public key used for commit signing";
    };

    barHeight = lib.mkOption {
      type = lib.types.int;
      default = 35;
      description = "Top bar height";
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

    desktop = {
      enable = lib.mkEnableOption "Enable graphical config";

      displayServer = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "xorg"
            "wayland"
          ]
        );
        default = if cfg.desktop.enable then "xorg" else null;
        description = "Display server to use";
      };

      terminal = lib.mkOption {
        type = lib.types.str;
        default = if cfg.desktop.displayServer == "xorg" then "alacritty" else "foot";
        description = "Default terminal emulator (needs to be valid pkg aswell)";
      };

      font = lib.mkOption {
        type = lib.types.str;
        default = "Terminess";
        description = "Default font";
      };

      optional = {
        gaming.enable = lib.mkEnableOption "Install steam and other game launchers";
        postgresql.enable = lib.mkEnableOption "Run a postgresql server";
        virtualBox.enable = lib.mkEnableOption "Enable virtual box";
        neo4j.enable = lib.mkEnableOption "Run a neo4j server";
      };
    };
  };
}
