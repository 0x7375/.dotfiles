{
  lib,
  pkgs,
  config,
  options,
  ...
}:

lib.mkMerge [
  {
    services.openssh = {
      enable = true;
      extraConfig = ''
        AllowUsers ${config.me.user}
        PermitRootLogin no
        KbdInteractiveAuthentication no

        Match Address ${config.me.networkIps.lan.subnet},${config.me.networkIps.vpn.subnet}
          AuthenticationMethods publickey

        Match All
          AuthenticationMethods "publickey,password"
      '';
    };
  }
  (lib.optionalAttrs (options ? services.fail2ban) {
    services.fail2ban = {
        enable = true;
        maxretry = 10;
      };
  })
  (lib.mkIf config.me.secrets.enable {
    sops.secrets."server_uni/server" = { };
    sops.secrets."server_uni/user" = { };

    system.activationScripts."ssh-secret-substitution" = ''
      server=$(cat "${config.sops.secrets."server_uni/server".path}")
      user=$(cat "${config.sops.secrets."server_uni/user".path}")
      configFile=/etc/ssh/ssh_config
      ${lib.getExe' pkgs.gnused "sed"} -i "s#@server@#$server#" "$configFile"
      ${lib.getExe' pkgs.gnused "sed"} -i "s#@user@#$user#" "$configFile"
    '';

    programs.ssh.extraConfig = ''
      Host web
        HostName @server@
        User @user@
    '';
  })
]
