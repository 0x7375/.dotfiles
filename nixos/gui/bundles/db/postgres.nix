{ config, lib, ... }:

lib.mkIf config.me.gui.bundles.postgresql.enable {
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
