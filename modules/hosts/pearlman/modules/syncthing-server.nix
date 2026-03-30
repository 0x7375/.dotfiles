{
  flake.nixos.pearlman =
    {
      lib,
      config,
      ...
    }:
    let
      inherit (config.me) hostname services;
      inherit (services.syncthing) port;
      cray = "cray";
      naitoh = "naitoh";
      cutler = "cutler";
      shannon = "shannon";
      lamarr = "lamarr";
      yoshino = "yoshino";
      mach = "mach";
      groups = {
        desktops = [
          cray
          naitoh
          cutler
          mach
        ];
        linux = [
          cray
          naitoh
          mach
        ];
        phones = [
          shannon
          lamarr
        ];
      };
    in
    {
      me.services.syncthing = {
        subdomain = "sync";
        port = 8384;
      };

      me.hostSecrets."syncthing/key" = {
        owner = "syncthing";
      };
      sops.secrets.syncthing_pw.owner = "syncthing";

      users.users.syncthing.extraGroups = [ "media" ];

      systemd.tmpfiles.settings.syncthing."/mnt/ssd/syncthing".d = {
        group = "syncthing";
        mode = "0755";
        user = "syncthing";
      };

      # allow watching more files
      boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

      networking.firewall.allowedTCPPorts = [ port ];

      services.syncthing = {
        enable = lib.mkForce true;
        guiAddress = "0.0.0.0:${toString port}";
        openDefaultPorts = true;
        settings = {
          devices =
            let
              syncthingHosts = lib.filterAttrs (n: v: v.syncthing.id != null && n != hostname) config.me.hosts;
            in
            lib.mapAttrs (_: v: { inherit (v.syncthing) id; }) syncthingHosts;
        };
      };
      me.syncthing = {
        dataRoot = "/mnt/ssd/syncthing/";

        folders = {
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

          zsh_history = {
            path = "zsh";
            devices = groups.linux;
            ignorePatterns = [
              "machine_id"
              "history"
            ];
          };

          pictures = {
            path = "pictures";
            devices = groups.desktops;
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
      };
    };
}
