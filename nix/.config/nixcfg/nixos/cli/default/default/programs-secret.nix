{
  secrets,
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.secrets.enable {
  age.secrets.uni-ssh-server = {
    file = "${secrets}/uni-ssh-server.age";
  };

  age.secrets.uni-ssh-user = {
    file = "${secrets}/uni-ssh-user.age";
  };

  age.secrets.uni-git-config = {
    file = "${secrets}/uni-git-config.age";
    owner = config.me.user;
  };

  system.activationScripts."ssh-secret-substitution" = ''
    server=$(cat "${config.age.secrets.uni-ssh-server.path}")
    user=$(cat "${config.age.secrets.uni-ssh-user.path}")
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
          path = config.age.secrets.uni-git-config.path;
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
