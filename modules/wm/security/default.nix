{
  config,
  mkNixos,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
  security.polkit.enable = true;

  systemd.user.services.polkit-gnome = {
    description = "GNOME PolicyKit Agent";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    wantedBy = [ "graphical-session.target" ];

    serviceConfig.ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
  };

  packages = with pkgs; [
    protonvpn-gui
    polkit_gnome
  ];

  xdg.desktopEntries.bitwarden = {
    exec = "${lib.getExe pkgs.helium} --app=http://vault.bitwarden.com";
    name = "Bitwarden";
    type = "Application";
  };

  me.wm.floating = [
    {
      type = "title";
      name = "Bitwarden Web vault";
      enable = false;
    }
  ];
})
