{
  lib,
  pkgs,
  config,
  options,
  mkBundle,
  ...
}:

lib.mkMerge [
  (mkBundle {
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

    darwin.programs.ssh.extraConfig =
      let
        validHosts = lib.filterAttrs (_: v: v.ips.lan != null) config.me.hosts;
        hostEntries = lib.mapAttrsToList (h: v: ''
          Host ${h}
            HostName ${v.ips.lan}
        '') validHosts;
      in
      builtins.concatStringsSep "\n" hostEntries;

    nixos.services.fail2ban = {
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
