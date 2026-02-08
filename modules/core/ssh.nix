{
  lib,
  config,
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

    # darwin.programs.ssh.extraConfig =
    #   let
    #     validHosts = lib.filterAttrs (_: v: v.ips.lan != null) config.me.hosts;
    #     hostEntries = lib.mapAttrsToList (h: v: ''
    #       Host ${h}
    #         HostName ${v.ips.lan}
    #     '') validHosts;
    #   in
    #   builtins.concatStringsSep "\n" hostEntries;

    nixos.services.fail2ban = {
      enable = true;
      maxretry = 10;
    };
  })

  (lib.mkIf config.me.secrets.enable {
    sops.secrets."server_uni/server" = { };
    sops.secrets."server_uni/user" = { };

    activation =
      let
        target = "/etc/ssh/ssh_config.d/999-secrets.conf";
      in
      ''
        server=$(cat "${config.sops.secrets."server_uni/server".path}")
        user=$(cat "${config.sops.secrets."server_uni/user".path}")

        cat <<EOF > "${target}"
        Host web
          HostName $server
          User $user
        EOF

        chmod g+r,o+r "${target}"
      '';
  })
]
