{ self, ... }:

{
  flake.modules.nixos.syncthingClient =
    { config, ... }:
    let
      inherit (config.me) user server home;
    in
    {
      imports = [
        self.modules.nixos.syncthing
      ];

      persistUser.directories = [ ".config/syncthing" ];
      programs.fuse.userAllowOther = true;

      me.hostSecrets."syncthing/key".owner = user;
      me.syncthing.dataRoot = "${home}/";
      sops.secrets.syncthing_pw.owner = user;

      services.syncthing = {
        inherit user;
        dataDir = home;
        settings.devices.${server}.id = config.me.hosts.${server}.syncthing.id;
      };
    };
}
