{
  config,
  myLib,
  pkgs,
  ...
}:

{
  services.qbittorrent = {
    enable = true;
    group = myLib.media-group;
    package = pkgs.auto.qbittorrent-nox;
    openFirewall = true;
    # setting this forces config to be declarative
    # serverConfig = {
    #   LegalNotice.Accepted = true;
    # };
  };

  security.polkit.extraConfig =
    # js
    ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "wg-quick-proton.service" &&
            subject.user == "${config.services.qbittorrent.user}") {
          return polkit.Result.YES;
        }
      });
    '';
}
