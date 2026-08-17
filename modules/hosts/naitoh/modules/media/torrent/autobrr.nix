{ self, ... }:

{
  flake.modules.nixos.naitoh =
    {
      config,
      pkgs,
      ...
    }:
    let
      ratioFilter = pkgs.rustPlatform.buildRustPackage {
        pname = "ratio-filter";
        version = "0";
        src = ./_ratio-filter;
        cargoLock.lockFile = ./_ratio-filter/Cargo.lock;
      };
    in
    {
      me.services.autobrr = {
        subdomain = "auto";
        inherit (config.services.autobrr.settings) port;
      };

      me.hostSecrets.autobrr_session.owner = config.services.qbittorrent.user;

      systemd.services.autobrr = self.lib.afterSopsService;

      services.autobrr = {
        enable = true;
        openFirewall = true;
        package = pkgs.auto.autobrr;
        secretFile = config.sops.secrets.autobrr_session.path;
        settings = {
          host = "0.0.0.0";
          checkForUpdates = false;
        };
      };

      systemd.services.ratio-filter = {
        script = ''
          PW=$(cat "${config.sops.secrets."qbittorrent/pw".path}")
          ${ratioFilter}/bin/ratio-filter http://localhost:${toString config.nixflix.torrentClients.qbittorrent.webuiPort} $PW
        '';
        serviceConfig = {
          Type = "oneshot";
          User = config.services.qbittorrent.user;
          StateDirectory = "ratio-filter";
          WorkingDirectory = "%S/ratio-filter";
        };
      };

      systemd.timers.ratio-filter = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
    };
}
