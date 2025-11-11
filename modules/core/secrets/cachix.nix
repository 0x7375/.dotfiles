{
  config,
  lib,
  ...
}:

lib.mkIf config.me.secrets.enable {
  sops.secrets.cachix = { };

  services.cachix-watch-store = {
    enable = true;
    cacheName = "ayko";
    cachixTokenFile = config.sops.secrets.cachix.path;
  };

  systemd.services.cachix-watch-store-agent.serviceConfig = {
    KillMode = lib.mkForce "control-group";
    KillSignal = "SIGTERM";
  };

  nix.settings = {
    substituters = [ "https://ayko.cachix.org" ];
    trusted-public-keys = [ "ayko.cachix.org-1:pglseKMD4PGHDRvF4LzDJKXOo0gSj3yWZU6QXI6YkBs=" ];
  };
}
