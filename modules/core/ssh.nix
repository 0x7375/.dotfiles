{
  lib,
  config,
  mkBundle,
  ...
}:

lib.mkMerge [
  (mkBundle {
    users.users.${config.me.user}.openssh.authorizedKeys.keys = config.me.hosts.yubikey.sshPublicKeys;

    services.openssh = {
      enable = true;
      extraConfig = ''
        AllowUsers ${config.me.user}
        PermitRootLogin no
        PasswordAuthentication no
        KbdInteractiveAuthentication no
        AuthenticationMethods publickey
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
        targetDir = dirOf target;
      in
      ''
        mkdir -p "${targetDir}"

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
