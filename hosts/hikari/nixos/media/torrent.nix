{
  config,
  myLib,
  pkgs,
  ...
}:

{
  services.qBittorrent = {
    enable = true;
    group = myLib.media-group;
    package = pkgs.auto.qbittorrent-nox;
    openFirewall = true;
  };

  security.polkit.extraConfig =
    # js
    ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "wg-quick-proton.service" &&
            subject.user == "${config.services.qBittorrent.user}") {
          return polkit.Result.YES;
        }
      });
    '';
}
