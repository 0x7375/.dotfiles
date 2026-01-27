{
  mkNixos,
  config,
  lib,
  ...
}:

lib.mkIf config.me.wm.optional.postgresql.enable (mkNixos {
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
})
