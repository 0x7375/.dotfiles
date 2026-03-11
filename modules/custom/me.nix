{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.me;
  inherit (lib) mkOption types mkEnableOption;

  mkCmdType =
    extraOpts:
    types.attrsOf (
      types.coercedTo (types.either types.str types.package) (cmd: { cmd = "${cmd}"; }) (
        types.submodule {
          options = {
            cmd = mkOption { type = types.str; };
          }
          // extraOpts;
        }
      )
    );

  mkRuleType =
    extraOpts:
    types.listOf (
      types.submodule {
        options = {
          type = mkOption {
            type = types.enum [
              "class"
              "title"
            ];
            default = "class";
          };
          name = mkOption { type = types.str; };
        }
        // extraOpts;
      }
    );
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

    server = mkOption {
      type = types.str;
      default = "pearlman";
      description = "Server hostname";
    };

    uid = mkOption {
      type = types.int;
      default = 1000;
      description = "User id";
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

    barHeight = mkOption {
      type = types.int;
      default = 35;
      description = "Top bar height";
      internal = true;
    };

    barFontSize = mkOption {
      type = types.int;
      default = 13;
      description = "Top bar font size";
      internal = true;
    };

    wm = {
      enable = mkEnableOption "Enable graphical config";

      bindings = mkOption {
        type = mkCmdType {
          release = mkEnableOption "create a release binding";
        };
        default = { };
      };

      startup = mkOption {
        type = mkCmdType {
          always = mkEnableOption "run on window-manager restart";
        };
        default = { };
      };

      floating = mkOption {
        type = mkRuleType {
          enable = mkOption {
            type = types.bool;
            default = true;
          };
        };
        default = [ ];
      };

      assign = mkOption {
        type = mkRuleType {
          workspace = mkOption { type = types.str; };
        };
        default = [ ];
      };

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

      open = mkOption {
        type = lib.types.str;
        default = if pkgs.stdenv.isDarwin then "open" else lib.getExe' pkgs.xdg-utils "xdg-open";
      };

      copy =
        let
          inherit (lib) getExe' getExe;
        in
        mkOption {
          type = lib.types.str;
          default =
            if pkgs.stdenv.isDarwin then
              "pbcopy"
            else if config.me.wm.displayServer == "wayland" then
              getExe' pkgs.wl-clipboard "wl-copy"
            else
              "${getExe pkgs.xsel} -ib";
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
    };
  };
}
