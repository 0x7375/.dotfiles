{ self, ... }:

{
  flake.modules.nixos.secrets =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.me.services.attic) url;
    in
    {
      sops.secrets.attic_access_token.owner = config.me.user;

      sops.templates.attic_netrc = {
        owner = config.me.user;
        content = ''
          machine cache.0xaa.me
          login attic
          password ${config.sops.placeholder.attic_access_token}
        '';
      };

      packages = [ pkgs.attic-client ];

      systemd.services.attic-watch-store = {
        description = "Attic watch store";
        wantedBy = [ config.me.target ];
        environment.ATTIC_SERVER = url;
        serviceConfig = {
          LoadCredential = [ "token:${config.sops.secrets.attic_access_token.path}" ];

          ExecStartPre = pkgs.writeShellScript "attic-login" ''
            TOKEN=$(cat $CREDENTIALS_DIRECTORY/token)
            ${lib.getExe pkgs.attic-client} login local ${url} $TOKEN
          '';
          ExecStart = "${lib.getExe pkgs.attic-client} watch-store default";
          Restart = "always";
          RestartSec = 3;
          KillMode = "control-group";
          KillSignal = "SIGTERM";
        };
      };

      nix.settings = {
        substituters = [ "${url}/default" ];
        trusted-public-keys = [ "default:VbeXg6jEaGj+UQTVyrZIMsyUCZy8Qooy4DiRyrqsikM=" ];
        netrc-file = config.sops.templates.attic_netrc.path;
      };
    };
}
