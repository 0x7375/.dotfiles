{
  config,
  secrets,
  lib,
  mkNixos,
  pkgs,
  ...
}:

let
  inherit (config.me.services.attic) url;
in
lib.mkIf config.me.secrets.enable (mkNixos {
  sops.secrets.attic = {
    sopsFile = "${secrets}/attic.env";
    format = "dotenv";
    key = "";
  };

  packages = [ pkgs.attic-client ];

  systemd.services.attic-watch-store = {
    description = "Attic watch store";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment.ATTIC_SERVER = url;
    serviceConfig = {
      ExecStartPre = "${lib.getExe pkgs.attic-client} login local ${url} $ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64";
      ExecStart = "${lib.getExe pkgs.attic-client} watch-store cache";
      Restart = "on-failure";
      KillMode = "control-group";
      KillSignal = "SIGTERM";
      EnvironmentFile = config.sops.secrets.attic.path;
    };
  };

  nix.settings = {
    substituters = [ "${url}/cache" ];
    trusted-public-keys = [ "cache:Xz8qsbtj34UcTg4kOCrJT3FuPTE+t7YM2iabg/qK/TQ=" ];
  };
})
