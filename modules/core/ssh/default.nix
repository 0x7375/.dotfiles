{
  lib,
  config,
  mkBundle,
  ...
}:

lib.mkMerge [
  (mkBundle {
    users.users.${config.me.user}.openssh.authorizedKeys.keys = config.me.hosts.yubikey.sshPublicKeys;

    programs.ssh.extraConfig = ''
      Host pearlman
        ForwardAgent yes
    '';

    hj.files.".ssh/sk_main" = {
      text = builtins.readFile ./sk_main;
      type = "copy";
      permissions = "0600";
    };

    hj.files.".ssh/sk_backup" = {
      text = builtins.readFile ./sk_backup;
      type = "copy";
      permissions = "0600";
    };

    services.openssh = {
      enable = true;
      extraConfig = ''
        AllowUsers ${config.me.user} root
        PasswordAuthentication no
        KbdInteractiveAuthentication no
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
    sops.secrets."uni_web_server/url" = { };
    sops.secrets."uni_web_server/user" = { };

    system.activationScripts.sshConfigFromSecrets = {
      deps = [ "setupSecrets" ];
      text =
        let
          target = "/etc/ssh/ssh_config.d/999-secrets.conf";
          targetDir = dirOf target;
        in
        # bash
        ''
          mkdir -p "${targetDir}"

          url=$(cat "${config.sops.secrets."uni_web_server/url".path}")
          user=$(cat "${config.sops.secrets."uni_web_server/user".path}")

          cat <<EOF > "${target}"
          Host web
            HostName $url
            User $user
          EOF

          chmod g+r,o+r "${target}"
        '';
    };
  })
]
