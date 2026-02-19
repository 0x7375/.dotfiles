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
          sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJahc82zjVv6+UDKi3eN9oZRfGRE7zhBivo5TYtDLe53";
          syncthingId = "E5O7YJW-QG5GRP2-GTOIL44-GARB6IA-KVLTV4L-PNELNSW-U54NY7P-N3R5NQW";
          ips.lan = "192.168.1.120";
        };
        naitoh = {
          sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH9wtfhfEPZ6GVA4FWRUk5KXtTttn6Q4qjxO1apMc7RK";
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
          sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVezt2Z6LhXPzAMhn6nJ0zXbrWXd93+QKmBqJ+8uE+s";
          ips = {
            lan = "192.168.1.95";
            vpn = "10.0.0.1";
          };
        };
        mach = {
          syncthingId = "32SVOZP-RJL755K-D7ZTMRL-7FOTZZF-V7W5V5J-2JOIMCG-W6MRDGK-AO4D4AC";
          sshPublicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLePZnDLZNnXzR5vgtmdu+fDEKu3GH87jM2EjSyBIF/0fEL8WPf9MkWRTsa3CY8bf+1SlFqUiGrtrMzyDx4fnPg=";
          ips = {
            lan = "192.168.1.168";
            vpn = "10.0.0.5";
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
        yoshino = {
          syncthingId = "4J5QS3L-TBUVQNM-RID2OP7-RTQG4GA-NWRB2E5-HXMTK7R-4C4QBFL-7M3RDAU";
          ips.vpn = "10.0.0.6";
        };
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
          bg0_dark = "#1d2021";

          bg0 = "#282828";
          bg1 = "#3c3836";
          bg2 = "#504945";
          bg3 = "#665c54";
          fg4 = "#a89984";
          fg3 = "#bdae93";
          fg2 = "#d5c4a1";
          fg1 = "#ebdbb2";
          fg0 = "#fbf1c7";

          red = "#fb4934";
          green = "#b8bb26";
          yellow = "#fabd2f";
          cyan = "#8ec07c";
          blue = "#83a598";
          magenta = "#d3869b";
          orange = "#fe8019";

          sleep = "#d3869b";
        };
        light = {
          _theme = "light";
          bg0_dark = "#f9f5d7";

          bg0 = "#fbf1c7";
          bg1 = "#ebdbb2";
          bg2 = "#d5c4a1";
          bg3 = "#bdae93";
          fg4 = "#7c6f64";
          fg3 = "#665c54";
          fg2 = "#504945";
          fg1 = "#3c3836";
          fg0 = "#282828";

          red = "#9d0006";
          yellow = "#b57614";
          green = "#79740e";
          cyan = "#427b58";
          blue = "#076678";
          magenta = "#8f3f71";
          orange = "#af3a03";

          sleep = "#8f3f71";
        };
      };
      description = "Color palette";
      internal = true;
    };

    hex = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      default =
        let
          map' = lib.mapAttrs (name: value: lib.removePrefix "#" value);
        in
        {
          dark = map' cfg.palette.dark;
          light = map' cfg.palette.light;
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
      description = "Setup network and create NetworkManager profiles";
    };

    secrets.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Deploy secrets using sops-nix";
    };

    vpnPeer.enable = mkEnableOption "Setup wireguard vpn peer";

    keyd.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Remap keys using keyd and keyd-application-mapper";
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
            "macos"
          ]
        );
        default = if cfg.wm.enable then "xorg" else null;
        description = "Display server to use";
      };

      terminal = mkOption {
        type = types.nullOr types.str;
        default =
          if cfg.wm.displayServer == "xorg" then
            "alacritty"
          else if cfg.wm.displayServer == "wayland" then
            "foot"
          else
            "xterm-256color";
        description = "Default terminal emulator";
      };

      fontSize = mkOption {
        type = types.int;
        default = 18;
        description = "Default font";
      };

      font = mkOption {
        type = types.str;
        default = "0xproto";
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
