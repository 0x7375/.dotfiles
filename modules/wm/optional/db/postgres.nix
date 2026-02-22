{
  mkNixos,
  config,
  lib,
  ...
}:

{
  options.me.wm.optional.postgresql.enable = lib.mkEnableOption "Run a postgresql server";

  config = lib.mkIf config.me.wm.optional.postgresql.enable (mkNixos {
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
  });
}
