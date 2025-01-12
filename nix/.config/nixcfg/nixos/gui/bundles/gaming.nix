{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.bundles.gaming.enable {
  nixpkgs.overlays = [
    (final: prev: {
      steam = prev.steam.override {
        extraBwrapArgs = [
          "--bind $HOME/.local/share/steam $HOME"
          "--unsetenv XDG_CACHE_HOME"
          "--unsetenv XDG_CONFIG_HOME"
          "--unsetenv XDG_DATA_HOME"
          "--unsetenv XDG_STATE_HOME"
        ];
      };
    })
  ];

  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
  };

  environment.systemPackages = with pkgs; [
    # protontricks
    # winetricks
    # wine
    protonup
    heroic
    # modrinth-app
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${config.me.user}/.steam/root/compatibilitytools.d";
  };
}
