{
  config,
  lib,
  ...
}:

lib.mkIf (config.me.syncthing-client.enable && config.me.secrets.enable) {
  programs.fuse.userAllowOther = true;

  hj.xdg.config.files."Ryujinx/.stignore".text = ''
    !/bis/user
    !/bis/system/save
    **
  '';

  services.syncthing = {
    settings = {
      devices = {
        "server" = {
          id = "A4SN3P4-3UDLBHB-X3IG2A3-AZCXD5S-SQ6CTOY-SN3STI2-LVUGEP7-VT4X7A4";
        };
      };
      folders = with lib.my; {
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
        switch = syncthingDirConfig {
          path = "games/switch";
          devices = [
            "server"
          ];
        };
        ryujinx = syncthingDirConfig {
          path = ".config/Ryujinx";
          devices = [
            "server"
          ];
        };
        gamecube = syncthingDirConfig {
          path = "games/gamecube";
          devices = [
            "server"
          ];
        };
        dolphin = syncthingDirConfig {
          path = ".local/share/dolphin-emu/StateSaves";
          devices = [
            "server"
          ];
        };
        arbtt = syncthingDirConfig {
          path = ".local/state/arbtt";
          devices = [
            "server"
          ];
        };
        zsh_history = syncthingDirConfig {
          path = ".local/state/zsh";
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
        courses = syncthingDirConfig {
          path = "courses";
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
