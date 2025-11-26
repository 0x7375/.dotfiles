{
  config,
  lib,
  ...
}:

let
  server = "wilson";
in
lib.mkIf (config.me.syncthing-client.enable && config.me.secrets.enable) {
  programs.fuse.userAllowOther = true;

  services.syncthing.settings.devices.${server}.id = config.me.hosts.${server}.syncthingId;
  me.syncthing.folders = {
    ds.path = "games/ds";
    switch.path = "games/switch";
    gamecube.path = "games/gamecube";
    dolphin.path = ".local/share/dolphin-emu/StateSaves";
    ryujinx.path = ".config/Ryujinx";

    windows.path = "windows";

    arbtt = {
      path = ".local/state/arbtt";
      ignorePatterns = [ "capture.log.lck" ];
    };

    zsh_history = {
      path = ".local/state/zsh";
      ignorePatterns = [ "history" ];
    };

    documents.path = "documents";
    pictures.path = "pictures";
    photos.path = "photos";
    uni.path = "uni";
    perso.path = "perso";

    notes.path = "notes";
    courses.path = "courses";
  };
}
