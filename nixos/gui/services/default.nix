{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.me.gui.enable {
  packages = with pkgs; [
    playerctl

    easyeffects
    at-spi2-core
  ];

  systemd.user.services.playerctld = {
    description = "MPRIS media player daemon";

    wantedBy = [ "default.target" ];

    serviceConfig = {
      ExecStart = lib.getExe' pkgs.playerctl "playerctld";
      Type = "dbus";
      BusName = "org.mpris.MediaPlayer2.playerctld";
    };
  };

  systemd.user.services.polkit-gnome = {
    description = "GNOME PolicyKit Agent";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    wantedBy = [ "graphical-session.target" ];

    serviceConfig.ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
  };

  hj.xdg.config.files = lib.mapAttrs' (
    k: v:
    # Assuming only one of either input or output block is defined, having both in same file not seem to be supported by the application since it separates it by folder
    let
      folder = builtins.head (builtins.attrNames v);
    in
    lib.nameValuePair "easyeffects/${folder}/${k}.json" {
      source = (pkgs.formats.json { }).generate "${folder}-${k}.json" v;
    }
  ) (builtins.fromJSON (builtins.readFile ./easyeffects.json));

  systemd.user.services.easyeffects = {
    description = "Easyeffects daemon";
    requires = [ "dbus.service" ];
    after = [ "graphical-session.target" ];
    partOf = [
      "graphical-session.target"
      "pipewire.service"
    ];

    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.easyeffects} --gapplication-service --load-preset defaut";
      ExecStop = "${lib.getExe pkgs.easyeffects} --quit";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
