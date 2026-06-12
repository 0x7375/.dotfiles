{
  flake.modules.nixos.syncthing =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.me.syncthing;
      inherit (config.me) hostname;
      isServer = hostname == config.me.server;

      inherit (lib) mkOption types;

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

      folderSubmodule =
        { name, config, ... }:
        {
          options = {
            devices = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
            path = mkOption {
              type = types.str;
              default = name;
            };
            serverPath = mkOption {
              type = types.str;
              default = config.path;
            };
            ignorePatterns = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
          };
        };

      activeFolders = lib.filterAttrs (_: f: isServer || lib.elem hostname f.devices) cfg.folders;
    in
    {
      options.me.syncthing = {
        dataRoot = mkOption {
          type = types.str;
          default = "~/";
        };
        folders = mkOption {
          type = types.attrsOf (types.submodule folderSubmodule);
          default = { };
        };
      };

      config = {
        services.syncthing.settings.folders = lib.mapAttrs (_: f: {
          path = cfg.dataRoot + (if isServer then f.serverPath else f.path);
          devices = if isServer then f.devices else [ config.me.server ];
          ignorePatterns = defaultPatterns ++ f.ignorePatterns;
          versioning = {
            type = "simple";
            params = {
              keep = "5";
              cleanoutDays = "14";
            };
          };
        }) activeFolders;

        persist.directories = lib.optionals isServer (
          lib.mapAttrsToList (_: f: cfg.dataRoot + f.serverPath) activeFolders
        );

        persistUser.directories = lib.optionals (!isServer) (
          lib.mapAttrsToList (_: f: f.path) activeFolders
        );
      };
    };
}
