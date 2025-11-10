{
  config,
  pkgs,
  ...
}:

{
  services.radarr = {
    enable = true;
    group = config.me.mediaGroup;
    package = pkgs.auto.radarr;
    openFirewall = true;
  };
}
