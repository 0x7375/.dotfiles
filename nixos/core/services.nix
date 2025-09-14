{
  myLib,
  lib,
  config,
  ...
}:

{
  services = {
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

    xserver = {
      xkb.options = "compose:ralt";
      autoRepeatDelay = 200;
      autoRepeatInterval = 30;
    };

    cachix-watch-store = lib.mkIf config.me.secrets.enable {
      enable = true;
      cacheName = "ayko";
      cachixTokenFile = config.sops.secrets.cachix.path;
    };
  };
}
