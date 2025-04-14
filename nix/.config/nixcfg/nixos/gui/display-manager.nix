{
  lib,
  config,
  ...
}:

lib.mkIf config.me.gui.enable {
  services.getty = {
    autologinOnce = true;
    autologinUser = config.me.user;
  };

  environment.etc.issue.text = "";

  services.xserver.displayManager.startx = {
    enable = true;
    generateScript = true;
    extraCommands =
      # bash
      ''
        if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
        	eval $(dbus-launch --exit-with-session --sh-syntax)
        fi
        systemctl --user import-environment DISPLAY XAUTHORITY

        if command -v dbus-update-activation-environment &> /dev/null; then
          dbus-update-activation-environment DISPLAY XAUTHORITY
        fi

        source ~/.profile
        export SHLVL=1
      '';
  };
}
