{
  lib,
  config,
  ...
}:

let
  inherit (config.me) hostname;
  cray = "cray";
  naitoh = "naitoh";
  cutler = "cutler";
  shannon = "shannon";
  lamarr = "lamarr";
  yoshino = "yoshino";
  groups = {
    desktops = [
      cray
      naitoh
      cutler
    ];
    linux = [
      cray
      naitoh
    ];
    phones = [
      shannon
      lamarr
    ];
  };
in
lib.mkIf config.me.secrets.enable {
  networking.firewall.allowedTCPPorts = [ 8384 ];

  systemd.services = lib.my.notifyOnServiceFailure "syncthing";

  services.syncthing = {
    guiAddress = "0.0.0.0:8384";
    openDefaultPorts = true;
    settings = {
      devices =
        let
          syncthingHosts = lib.filterAttrs (n: v: v.syncthingId != null && n != hostname) config.me.hosts;
        in
        lib.mapAttrs (n: v: { id = v.syncthingId; }) syncthingHosts;
    };
  };
  me.syncthing.folders = {
    ds = {
      path = "games/ds";
      devices = groups.desktops;
    };
    switch = {
      path = "games/switch";
      devices = groups.desktops;
    };
    gamecube = {
      path = "games/gamecube";
      devices = groups.desktops;
    };
    dolphin = {
      path = "dolphin";
      devices = groups.desktops;
    };
    ryujinx = {
      path = "ryujinx";
      devices = groups.desktops;
      ignorePatterns = [
        "!/bis/user"
        "!/bis/system/save"
        "**"
      ];
    };

    windows = {
      path = "windows";
      devices = groups.desktops;
    };

    arbtt = {
      path = ".local/state/arbtt";
      devices = groups.linux;
      ignorePatterns = [ "capture.log.lck" ];
    };

    zsh_history = {
      path = ".local/state/zsh";
      devices = groups.linux;
    };

    pictures = {
      path = "pictures";
      devices = groups.desktops;
      ro = true;
    };
    documents = {
      path = "documents";
      devices = groups.linux ++ groups.phones;
      ro = true;
    };
    photos = {
      path = "photos";
      devices = groups.linux ++ groups.phones;
      ro = true;
    };
    perso = {
      path = "perso";
      devices = groups.linux;
    };
    uni = {
      path = "uni";
      devices = groups.linux;
      ro = true;
    };
    universite = {
      path = "documents/pdf/universite";
      devices = groups.phones;
    };

    courses = {
      path = "courses";
      devices = groups.desktops ++ groups.phones ++ [ yoshino ];
    };
    notes = {
      path = "notes";
      devices = groups.linux ++ groups.phones;
      ro = true;
    };
  };
}
