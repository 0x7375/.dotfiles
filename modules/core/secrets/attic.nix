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
      sops.secrets.attic_access_token = { };

      packages = [ pkgs.attic-client ];

      systemd.services.attic-watch-store = {
        description = "Attic watch store";
        wantedBy = [ "multi-user.target" ];
        after = [ "sops-install-secrets.service" ];
        requires = [ "sops-install-secrets.service" ];
        environment.ATTIC_SERVER = url;
        serviceConfig = {
          LoadCredential = [ "token:${config.sops.secrets.attic_access_token.path}" ];

          ExecStartPre = pkgs.writeShellScript "attic-login" ''
            TOKEN=$(cat $CREDENTIALS_DIRECTORY/token)
            ${lib.getExe pkgs.attic-client} login local ${url} $TOKEN
          '';
          ExecStart = "${lib.getExe pkgs.attic-client} watch-store cache";
          Restart = "on-failure";
          KillMode = "control-group";
          KillSignal = "SIGTERM";
        };
      };

      nix.settings = {
        substituters = [ "${url}/cache" ];
        trusted-public-keys = [ "cache:Vi/f16RngGbWkPLDlM/TBMOE+DEQcnvw8OFCUKdYgC4=" ];
      };
    };
}
