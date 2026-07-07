{
  flake.modules.generic.wayland =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.me.desktop;
    in
    {
      options.me.desktop = {
        modes = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "monitor name -> mode string, e.g. HDMI-A-1 = \"1920x1080@120Hz\"";
        };

        profiles = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                primary = lib.mkOption { type = lib.types.str; };
                monitors = lib.mkOption {
                  type = lib.types.attrsOf (
                    lib.types.submodule {
                      options = {
                        tags = lib.mkOption {
                          type = lib.types.listOf lib.types.str;
                          default = [ ];
                        };
                        position = lib.mkOption {
                          type = lib.types.submodule {
                            options = {
                              x = lib.mkOption { type = lib.types.int; };
                              y = lib.mkOption { type = lib.types.int; };
                            };
                          };
                          default = {
                            x = 0;
                            y = 0;
                          };
                        };
                      };
                    }
                  );
                  default = { };
                };
              };
            }
          );
          default = { };
        };

        kanshiConfig = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
          default = lib.concatStrings (
            lib.mapAttrsToList (name: profile: ''
              profile ${name} {
              ${lib.concatStrings (
                lib.mapAttrsToList (monitor: output: ''
                  output ${monitor} enable${
                    lib.optionalString (cfg.modes ? ${monitor}) " mode ${cfg.modes.${monitor}}"
                  } position ${toString output.position.x},${toString output.position.y}
                '') profile.monitors
              )}
                exec ${lib.getExe cfg.monitorScript} ${name}
              }
            '') cfg.profiles
          );
        };
      };

      config = {
        packages = [ pkgs.kanshi ];

        systemd.user.services.kanshi = {
          description = "kanshi";
          wantedBy = [ "mango-session.target" ];
          partOf = [ "mango-session.target" ];

          serviceConfig = {
            ExecStart = "${lib.getExe pkgs.kanshi}";
            Restart = "always";
            RestartSec = 3;
          };
        };

        hj.xdg.config.files."kanshi/config".text = cfg.kanshiConfig;
      };
    };
}
