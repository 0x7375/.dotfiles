{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.bundles.gaming.enable {
  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
  };

  environment.systemPackages = with pkgs; [
    protontricks
    # winetricks
    # wine
    protonup
    heroic
    steamtinkerlaunch
    # modrinth-app
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${config.me.user}/.steam/root/compatibilitytools.d";
  };
}
