{
  flake.nixos.syncthing =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.me.syncthing;
      inherit (lib)
        mkOption
        mkEnableOption
        types
        ;

      syncthingDirConfig =
        {
          path,
          devices,
          ignorePatterns ? [ ],
          type ? "sendreceive",
          extraConfig ? { },
        }:
        let
          defaultPatterns = [
            ".cache"
            ".git"
            "bin"
            "node_modules"
            ".venv"
            ".expo"
            "*.class"
            "*.o"
            "*.toc"
            "*.aux"
            "!capture.log"
            "*.log"
            "*.out"
            "*.idx"

            # windows
            "desktop.ini"

            # macos
            ".DS_Store"
            ".localized"
            "Photos Library.photoslibrary"
          ];
        in
        {
          path = cfg.dataRoot + path;
          inherit type;
          inherit devices;
          ignorePatterns = defaultPatterns ++ ignorePatterns;
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
              default = [ config.me.server ];
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
        client.enable = mkEnableOption "Setup folders";

        dataRoot = mkOption {
          type = types.str;
          default = "~/";
          description = "The base path where Syncthing folders are stored";
        };

        folders = mkOption {
          type = types.attrsOf (types.submodule folderSubmodule);
          default = { };
        };
      };

      config = {
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
                  inherit (f) devices;
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
      };
    };
}
