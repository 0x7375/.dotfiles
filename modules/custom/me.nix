{
  flake.modules.generic.custom =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.me;
      inherit (lib) mkOption types;
    in
    {
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

        target = mkOption {
          type = types.str;
          default = "multi-user.target";
          description = "Target to gate expensive services behind";
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
      };
    };
}
