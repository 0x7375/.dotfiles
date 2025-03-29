{
  pkgs,
  myLib,
  config,
  lib,
  ...
}:

lib.mkIf (config.me.syncthing-client.enable && config.me.secrets.enable) {
  programs.fuse.userAllowOther = true;

  services.syncthing = {
    settings = {
      devices = {
        "server" = {
          id = "A4SN3P4-3UDLBHB-X3IG2A3-AZCXD5S-SQ6CTOY-SN3STI2-LVUGEP7-VT4X7A4";
        };
      };
      folders = with myLib; {
        documents = syncthingDirConfig {
          path = "documents";
          devices = [
            "server"
          ];
        };
        uni = syncthingDirConfig {
          path = "uni";
          devices = [
            "server"
          ];
        };
        pictures = syncthingDirConfig {
          path = "pictures";
          devices = [
            "server"
          ];
        };
        ds = syncthingDirConfig {
          path = "games/ds";
          devices = [
            "server"
          ];
        };
        notes = syncthingDirConfig {
          path = "notes";
          devices = [
            "server"
          ];
        };
        perso = syncthingDirConfig {
          path = "perso";
          devices = [
            "server"
          ];
        };
        photos = syncthingDirConfig {
          path = "photos";
          devices = [
            "server"
          ];
        };
        zsh_history = syncthingDirConfig {
          path = ".local/state/zsh";
          devices = [
            "server"
          ];
          extraConfig = {
            maxConflicts = 0;
            ignoreDelete = true;
            ignore = [
              "*"
              "!history"
            ];
            versioning = {
              type = "external";
              params = {
                command = "${pkgs.scripts.merge-zsh}/bin/merge-zsh %FOLDER_PATH% %FILE_PATH%";
              };
            };
          };
        };
        windows = syncthingDirConfig {
          path = "windows";
          devices = [
            "server"
          ];
        };
      };
    };
  };
}
