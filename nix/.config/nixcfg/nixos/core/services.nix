{
  myLib,
  lib,
  config,
  ...
}:

{
  services = {
    locate.enable = true;

    fail2ban = {
      enable = true;
      maxretry = 5;
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
        Match Address ${config.me.allowedIPsRootLogin}
          AuthenticationMethods publickey

        Match All
          AuthenticationMethods "publickey,password"
      '';
    };

    udisks2.enable = true;

    xserver = {
      xkb = {
        layout = "pwerty";
        variant = "";
        model = "";
        options = "compose:ralt,altwin:swap_lalt_lwin";
        extraLayouts.pwerty = {
          description = "Modified qwerty for programming";
          languages = [ "eng" ];
          symbolsFile = myLib.fromRoot "assets/kb/pwerty";
        };
      };

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
