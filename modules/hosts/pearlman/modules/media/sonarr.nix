{
  flake.nixos.pearlman =
    {
      config,
      pkgs,
      ...
    }:
    {
      me.services.sonarr = {
        subdomain = "shows";
        port = 8989;
      };

      services.sonarr = {
        enable = true;
        group = config.me.mediaGroup;
        package = pkgs.auto.sonarr;
        openFirewall = true;
      };
    };
}
