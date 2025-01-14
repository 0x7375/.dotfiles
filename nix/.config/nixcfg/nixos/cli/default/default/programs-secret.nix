{
  secrets,
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.secrets.enable {
  sops.secrets."server_uni/server" = { };
  sops.secrets."server_uni/user" = { };

  sops.secrets.git-config = {
    sopsFile = "${secrets}/uni-git-config.ini";
    format = "ini";
    owner = config.me.user;
  };

  system.activationScripts."ssh-secret-substitution" = ''
    server=$(cat "${config.sops.secrets."server_uni/server".path}")
    user=$(cat "${config.sops.secrets."server_uni/user".path}")
    configFile=/etc/ssh/ssh_config
    ${pkgs.gnused}/bin/sed -i "s#@server@#$server#" "$configFile"
    ${pkgs.gnused}/bin/sed -i "s#@user@#$user#" "$configFile"
  '';

  programs = {
    ssh.extraConfig = ''
      Host web
        HostName @server@
        User @user@
    '';

    git = {
      config =
        let
          path = config.sops.secrets.git-config.path;
        in
        [
          {
            user = {
              name = "name";
              email = "email";
            };
          }
          {
            "includeIf \"hasconfig:remote.*.url:uni:*/**\"" = {
              inherit path;
            };
            "includeIf \"hasconfig:remote.*.url:forge:**\"" = {
              inherit path;
            };
          }
        ];
    };
  };
}
