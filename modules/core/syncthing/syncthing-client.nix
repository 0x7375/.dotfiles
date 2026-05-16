{ self, ... }:

{
  flake.modules.nixos.syncthingClient =
    {
      config,
      ...
    }:
    let
      inherit (config.me)
        user
        server
        home
        ;
    in
    {
      imports = [ self.modules.nixos.syncthing ];

      programs.fuse.userAllowOther = true;

      me.hostSecrets."syncthing/key" = {
        owner = user;
      };
      sops.secrets.syncthing_pw.owner = user;

      services.syncthing = {
        inherit user;
        settings.devices.${server}.id = config.me.hosts.${server}.syncthing.id;
        dataDir = home;
      };

      me.syncthing.folders = {
        ds.path = "games/ds";
        switch.path = "games/switch";
        gamecube.path = "games/gamecube";
        dolphin.path = ".local/share/dolphin-emu/StateSaves";
        ryujinx.path = ".config/Ryujinx";

        windows.path = "windows";

        zsh_history = {
          path = ".local/state/zsh";
          ignorePatterns = [
            "history"
            "machine_id"
          ];
        };

        documents.path = "documents";
        pictures.path = "pictures";
        photos.path = "photos";
        uni.path = "uni";
        perso.path = "perso";

        notes.path = "notes";
        courses.path = "courses";
      };
    };
}
