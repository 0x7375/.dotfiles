{ config, lib, ... }:

lib.mkIf config.me.gui.bundles.neo4j.enable {
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
}
