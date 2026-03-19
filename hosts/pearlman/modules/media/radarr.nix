{
  config,
  pkgs,
  ...
}:

{
  me.radarr = {
    subdomain = "movies";
    port = 7878;
  };

  services.radarr = {
    enable = true;
    group = config.me.mediaGroup;
    package = pkgs.auto.radarr;
    openFirewall = true;
  };
}
