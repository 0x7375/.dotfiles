{
  flake.modules.generic.core =
    {
      config,
      lib,
      ...
    }:
    {
      users.users.root.openssh.authorizedKeys.keys = config.me.hosts.yubikey.sshPublicKeys;
      users.users.${config.me.user}.openssh.authorizedKeys.keys = config.me.hosts.yubikey.sshPublicKeys;

      programs.ssh.extraConfig = ''
        Host *
          StrictHostKeyChecking accept-new
      ''
      + builtins.concatStringsSep "\n" (
        lib.map (v: "Host ${v}\n  ForwardAgent yes\n") [
          "pearlman"
          "cray"
          "naitoh"
          "woz"
        ]
      );

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

    };

  flake.modules.nixos.core =
    { config, ... }:
    {
      persist = {
        directories = [
        "/var/lib/fail2ban"
        {
          directory = "/etc/ssh";
          how = "_intermediate";
        }
      ];
        files = [
        { file = "/etc/ssh/ssh_host_ed25519_key"; how = "symlink"; }
        { file = "/etc/ssh/ssh_host_rsa_key"; how = "symlink"; }
        { file = "/etc/ssh/ssh_host_rsa_key.pub"; how = "symlink"; }
      ];
      };

      persistUser.directories = [
        {
          directory = ".ssh";
          mode = "0700";
        }
      ];

      services.openssh.settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = [
          config.me.user
          "root"
        ];
        PermitRootLogin = "prohibit-password"; # keys only for root
      };
    };
}
