{
  mkNixos,
  config,
  lib,
  ...
}:

let
  cfg = config.me.syncthing;
  inherit (lib) mkOption types mkIf;

  syncthingDirConfig =
    {
      path,
      devices,
      type ? "sendreceive",
      ignorePatterns ? [
        ".cache"
        "bin"
        "node_modules"
        ".expo"
        "*.class"
        "*.o"
        "*.toc"
        "*.aux"
        "*.log"
        "*.out"
        ".DS_Store"
      ],
      extraConfig ? { },
    }:
    {
      path = "~/" + path;
      inherit type;
      inherit devices;
      inherit ignorePatterns;
      versioning =
        if type != "sendonly" then
          {
            type = "simple";
            params = {
              keep = "5";
              cleanoutDays = "14";
            };
          }
        else
          null;
    }
    // extraConfig;

  folderSubmodule =
    { name, ... }:
    {
      options = {
        path = mkOption {
          type = types.str;
          default = name;
        };
        devices = mkOption {
          type = types.listOf types.str;
          default = [ "wilson" ];
        };
        ignorePatterns = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };

        ro = mkOption {
          type = types.bool;
          default = false;
        };
        roDevices = mkOption {
          type = types.listOf types.str;
          default = [ "cutler" ];
        };
      };
    };
in
{
  options.me.syncthing = {
    server = mkOption {
      type = types.str;
      default = "wilson";
      description = "Hostname of the central server";
    };

    folders = mkOption {
      type = types.attrsOf (types.submodule folderSubmodule);
      default = { };
    };
  };

  config = mkIf cfg.enable (mkNixos {
    services.syncthing.settings.folders = lib.foldl' lib.mergeAttrs { } (
      lib.mapAttrsToList (
        name: f:
        let
          baseArgs = {
            inherit (f) path ignorePatterns;
          };
        in
        {
          "${name}" = syncthingDirConfig (
            baseArgs
            // {
              devices = f.devices;
            }
          );
        }
        // lib.optionalAttrs f.ro {
          "${name}-ro" = syncthingDirConfig (
            baseArgs
            // {
              devices = f.roDevices;
              type = "sendonly";
            }
          );
        }
      ) cfg.folders
    );
  });
}
