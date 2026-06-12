{
  flake.modules.nixos.pearlman =
    {
      lib,
      config,
      self,
      ...
    }:
    let
      inherit (config.me) hostname services;
      inherit (services.syncthing) port;
    in
    {
      imports = [
        self.modules.nixos.syncthing
        self.modules.nixos.syncthingFolders
      ];

      me.services.syncthing = {
        subdomain = "sync";
        port = 8384;
      };

      me.hostSecrets."syncthing/key".owner = "syncthing";
      sops.secrets.syncthing_pw.owner = "syncthing";

      users.users.syncthing.extraGroups = [ "media" ];

      # allow watching more files
      boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

      networking.firewall.allowedTCPPorts = [ port ];

      me.syncthing.dataRoot = "/mnt/ssd/syncthing/";

      services.syncthing = {
        enable = lib.mkForce true;
        guiAddress = "0.0.0.0:${toString port}";
        openDefaultPorts = true;
        settings.devices =
          let
            syncthingHosts = lib.filterAttrs (n: v: v.syncthing.id != null && n != hostname) config.me.hosts;
          in
          lib.mapAttrs (_: v: { inherit (v.syncthing) id; }) syncthingHosts;
      };

      systemd.tmpfiles.settings.syncthing."/mnt/ssd/syncthing".d = {
        group = "syncthing";
        mode = "0755";
        user = "syncthing";
      };
    };
}
