{
  pkgs,
  myLib,
  lib,
  config,
  ...
}:

{
  packages = [ pkgs.arbtt-stats ];

  services = {
    arbtt = {
      enable = true;
      logFile = "%h/.local/state/arbtt/capture.log";
    };

    earlyoom.enable = true;

    locate.enable = true;

    fail2ban = {
      enable = true;
      maxretry = 10;
    };

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkDefault "prohibit-password";
        KbdInteractiveAuthentication = false;
        AllowUsers = [
          config.me.user
          "root"
        ];
      };
      extraConfig = ''
        Match Address ${myLib.network.lan.subnet},${myLib.network.vpn.subnet}
          AuthenticationMethods publickey

        Match All
          AuthenticationMethods "publickey,password"
      '';
    };

    cachix-watch-store = lib.mkIf config.me.secrets.enable {
      enable = true;
      cacheName = "ayko";
      cachixTokenFile = config.sops.secrets.cachix.path;
    };
  };

  systemd.services.cachix-watch-store-agent.serviceConfig = {
    KillMode = lib.mkForce "control-group";
    KillSignal = "SIGTERM";
  };
}
