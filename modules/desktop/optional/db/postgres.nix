{ config, lib, ... }:

lib.mkIf config.me.desktop.optional.postgresql.enable {
  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = config.me.user;
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ config.me.user ];
  };
}
