{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.bundles.gaming.enable {
  unfree-packages = [
    "steam"
    "steam-unwrapped"
  ];

  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
    protontricks.enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  packages = with pkgs; [
    winetricks
    wine64
    heroic
    steamtinkerlaunch
    # modrinth-app
    (bottles.override { removeWarningPopup = true; })
    lutris
    protonup-ng
  ];

  vars = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${config.me.user}/.steam/root/compatibilitytools.d";
    __GL_SYNC_DISPLAY_DEVICE = "HDMI-1"; # prevent gamescope for instance from locking fps to second monitor refresh rate
  };
}
