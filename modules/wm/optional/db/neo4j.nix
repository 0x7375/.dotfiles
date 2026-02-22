{
  mkNixos,
  config,
  lib,
  ...
}:

{
  options.me.wm.optional.neo4j.enable = lib.mkEnableOption "Run a neo4j server";

  config = lib.mkIf config.me.wm.optional.neo4j.enable (mkNixos {
    services.neo4j = {
      enable = true;
      bolt = {
        enable = true;
        tlsLevel = "DISABLED";
      };
      https.enable = false;
      extraServerConfig = ''
        server.config.strict_validation.enabled = false
        dbms.security.auth_enabled=false
      '';
      ssl.policies = {
        default = {
          allowKeyGeneration = true;
        };
      };
    };
  });
}
