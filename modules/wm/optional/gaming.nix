{
  mkNixos,
  config,
  lib,
  pkgs,
  ...
}:

{
  options.me.wm.optional.gaming.enable = lib.mkEnableOption "Install steam and other game launchers";

  config = lib.mkIf config.me.wm.optional.gaming.enable (mkNixos {
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

    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
        };
      };
    };

    packages = with pkgs; [
      winetricks
      wine64
      # heroic
      steamtinkerlaunch
      # modrinth-app
      (bottles.override { removeWarningPopup = true; })
      # lutris
      protonup-ng
    ];

    vars = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${config.me.home}/.steam/root/compatibilitytools.d";
      __GL_SYNC_DISPLAY_DEVICE = "HDMI-1"; # prevent gamescope for instance from locking fps to second monitor refresh rate
    };

    # prevent arc raiders from crashing mid loading
    boot.kernelParams = [
      "vsyscall=emulate"
    ];
  });
}
