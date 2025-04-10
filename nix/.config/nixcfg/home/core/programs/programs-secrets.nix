{
  lib,
  config,
  secrets,
  ...
}:

lib.mkIf config.me.secrets.enable {
  sops.secrets.wakatime = {
    sopsFile = "${secrets}/wakatime.cfg";
    format = "binary";
    key = "";
    path = "/home/${config.me.user}/.wakatime.cfg";
  };
}

