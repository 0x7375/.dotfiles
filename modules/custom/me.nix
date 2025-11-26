{
  config,
  lib,
  ...
}:

let
  cfg = config.me;
  inherit (lib) mkOption types mkEnableOption;

  hostSubmodule = {
    options = {
      sshPublicKey = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "SSH public key (null for devices like phones)";
      };
      syncthingId = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Syncthing Device ID";
      };
      ips = {
        lan = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Local Network IP";
        };
        vpn = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Wireguard/VPN IP";
        };
      };
    };
  };
in
{
  config = {
    assertions = [
      {
        assertion = cfg.wm.displayServer == null || cfg.wm.enable;
        message = "Display server '${cfg.wm.displayServer}' requires wm.enable to be true";
      }
    ];
  };

  options.me = {
    flakeDir = mkOption {
      type = types.str;
      default = "/home/${cfg.user}/.config/nixcfg";
      description = "Path to the nixos flake directory";
    };

    home = mkOption {
      type = types.str;
      default = "/home/${cfg.user}";
      description = "Home directory";
    };

    user = mkOption {
      type = types.str;
      default = "ayko";
      description = "User name";
    };

    browser = mkOption {
      type = types.str;
      default = "zen-beta";
      description = "Default browser";
    };

    uid = mkOption {
      type = types.int;
      default = 1000;
      description = "User id";
    };

    mediaGroup = mkOption {
      type = types.str;
      default = "media";
      description = "Media group name";
      internal = true;
    };

    barFontSize = mkOption {
      type = types.int;
      default = 13;
      description = "Top bar font size";
      internal = true;
    };

    hosts = mkOption {
      description = "Central infrastructure definition";
      internal = true;
      type = types.attrsOf (types.submodule hostSubmodule);

      default = {
        cray = {
          sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJahc82zjVv6+UDKi3eN9oZRfGRE7zhBivo5TYtDLe53 cray";
          syncthingId = "E5O7YJW-QG5GRP2-GTOIL44-GARB6IA-KVLTV4L-PNELNSW-U54NY7P-N3R5NQW";
          ips.lan = "192.168.1.120";
        };
        naitoh = {
          sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH9wtfhfEPZ6GVA4FWRUk5KXtTttn6Q4qjxO1apMc7RK naitoh";
          syncthingId = "VQTBWUL-XN5DIYJ-2FVH2L5-METP43G-QGVR6HG-4E5TGBC-3G6MUN4-EEUHGQB";
          ips = {
            lan = "192.168.1.198";
            vpn = "10.0.0.2";
          };
        };
        cutler.syncthingId = "XAFE3W3-FG4XVNB-GCPR4CU-XAYED7H-AISJHBI-JREWBFT-CLUTRPZ-EVYV5AH";
        julliard.sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcGpmfziJoYbPbfdZi/REVStrNgl+F8lwVf1t2oLdaZ julliard";
        wilson = {
          syncthingId = "A4SN3P4-3UDLBHB-X3IG2A3-AZCXD5S-SQ6CTOY-SN3STI2-LVUGEP7-VT4X7A4";
          sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVezt2Z6LhXPzAMhn6nJ0zXbrWXd93+QKmBqJ+8uE+s wilson";
          ips = {
            lan = "192.168.1.95";
            vpn = "10.0.0.1";
          };
        };
        shannon = {
          syncthingId = "JJ62FKA-U5HTR5S-NJ7A4EJ-TMO66SZ-QNUOYUA-CCQMUIB-STDX4RE-VCGEKAB";
          ips.vpn = "10.0.0.3";
        };
        lamarr = {
          syncthingId = "ZMUWGAS-D7ETM4C-77LZJQD-T3VBPZS-UWXFTVN-K32GD5G-XKCP4UG-OMRG4AA";
          ips.vpn = "10.0.0.4";
        };
        yoshino.syncthingId = "4J5QS3L-TBUVQNM-RID2OP7-RTQG4GA-NWRB2E5-HXMTK7R-4C4QBFL-7M3RDAU";
      };
    };

    host = mkOption {
      type = types.submodule hostSubmodule;
      default = cfg.hosts.${cfg.hostname};
      internal = true;
    };

    hostname = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = "System hostname";
    };

    networkIps = mkOption {
      type = types.attrsOf (types.attrsOf (types.either types.str (types.attrsOf types.str)));
      default = {
        lan = {
          subnet = "192.168.1.0/24";
          gateway = "192.168.1.254";
        };
        vpn = {
          subnet = "10.0.0.0/24";
        };
      };
      internal = true;
    };

    palette = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
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

          sleep = "#DDA0DD";
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

          sleep = "#8F4D8F";
        };
      };
      description = "Color palette";
      internal = true;
    };

    hex = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
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

    barHeight = mkOption {
      type = types.int;
      default = 35;
      description = "Top bar height";
    };

    cursorSize = mkOption {
      type = types.int;
      default = 24;
      description = "Cursor size";
    };

    refreshRate = mkOption {
      type = types.int;
      default = 60;
      description = "Refresh rate (used to choose the right config for firefox)";
    };

    boot = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Setup systemd boot with plymouth";
      };
      silent.enable = mkOption {
        type = types.bool;
        default = (!cfg.boot.debug.enable && cfg.boot.enable);
        description = "Enable silent boot";
      };
      debug.enable = mkEnableOption "Make boot verbose";
    };

    network.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Use nextdns and create NetworkManager profiles";
    };

    secrets.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Deploy secrets using sops-nix";
    };

    keyd.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Remap keys using keyd and keyd-application-mapper";
    };

    sleep.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Sleep reminders";
    };

    syncthing.enable = mkOption {
      type = types.bool;
      default = cfg.syncthing-client.enable;
      description = "Setup syncthing";
    };
    syncthing-client.enable = mkEnableOption "Enable syncthing client and setup directories";

    dev.enable = mkEnableOption "Install development packages";
    minecraft.enable = mkEnableOption "Create minecraft server";
    capsLockRemap.enable = mkEnableOption "Remap caps lock to control/esc using interception-tools";
    btrfs.enable = mkEnableOption "Enable autoscrub and automatic home snapshots";

    wm = {
      enable = mkEnableOption "Enable graphical config";

      displayServer = mkOption {
        type = types.nullOr (
          types.enum [
            "xorg"
            "wayland"
          ]
        );
        default = if cfg.wm.enable then "xorg" else null;
        description = "Display server to use";
      };

      terminal = mkOption {
        type = types.str;
        default = if cfg.wm.displayServer == "xorg" then "alacritty" else "foot";
        description = "Default terminal emulator (needs to be valid pkg aswell)";
      };

      font = mkOption {
        type = types.str;
        default = "Terminess";
        description = "Default font";
      };

      optional = {
        gaming.enable = mkEnableOption "Install steam and other game launchers";
        postgresql.enable = mkEnableOption "Run a postgresql server";
        virtualBox.enable = mkEnableOption "Enable virtual box";
        neo4j.enable = mkEnableOption "Run a neo4j server";
      };
    };
  };
}
