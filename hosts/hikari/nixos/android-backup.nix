{
  pkgs,
  config,
  ...
}:

let
  bak_user = "androidbackup";
in
{
  users.users.${bak_user} = {
    isNormalUser = true;
    uid = 1111;
    home = "/srv/${bak_user}";
    shell = pkgs.bashInteractive;
    createHome = false;
    extraGroups = [ "sambashare" ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/${bak_user} 0755 root root -"
    "d /srv/${bak_user}/data 0755 ${bak_user} sambashare -"
  ];

  sops.secrets."hikari/samba_pass" = { };

  system.activationScripts.sambaUserSetup = {
    deps = [ "setupSecrets" ];

    text =
      # bash
      ''
        if ! ${pkgs.samba}/bin/pdbedit -L | grep -q '^${bak_user}:'; then
          ${pkgs.samba}/bin/pdbedit \
            -i smbpasswd:${config.sops.secrets."hikari/samba_pass".path} \
            -e tdbsam:/var/lib/samba/private/passdb.tdb
        fi
      '';
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        security = "user";
        "hosts allow" = "192.168.1. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "valid users" = "${bak_user}";
      };
      "private" = {
        path = "/srv/${bak_user}/data";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${bak_user}";
        "force group" = "users";
      };
    };
  };
}
