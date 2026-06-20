{
  flake.modules.nixos.syncthing =
    {
      pkgs,
      config,
      ...
    }:
    let
      afterSops = {
        after = [ "sops-install-secrets.service" ];
        requires = [ "sops-install-secrets.service" ];
      };
    in
    {
      systemd.services.syncthing-init = afterSops // {
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
      systemd.services.syncthing = afterSops;

      # allow watching more files
      boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

      services.syncthing = {
        enable = true;
        package = pkgs.syncthing;
        overrideDevices = true;
        overrideFolders = true;
        guiPasswordFile = config.sops.secrets.syncthing_pw.path;
        key = config.sops.secrets."syncthing/key".path;
        cert = "${pkgs.writeText "cert" ''
          -----BEGIN CERTIFICATE-----
          ${config.me.host.syncthing.cert}
          -----END CERTIFICATE-----
        ''}";
        settings = {
          options = {
            urAccepted = -1;
            relaysEnabled = false;
          };
          gui.user = "admin";
        };
      };
    };
}
