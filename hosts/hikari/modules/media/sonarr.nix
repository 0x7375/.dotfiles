{
  config,
  pkgs,
  ...
}:

{
  services.sonarr = {
    enable = true;
    group = config.me.mediaGroup;
    package = pkgs.auto.sonarr;
    openFirewall = true;
  };
}
