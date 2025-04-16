{
  lib,
  config,
  ...
}:

lib.mkIf config.me.gui.enable {
  nixpkgs.overlays = [
    (final: prev: {
      xorg = prev.xorg.overrideScope (
        xFinal: xPrev: {
          xinit = xPrev.xinit.overrideAttrs (old: {
            postInstall =
              (old.postInstall or "")
              + ''
                substituteInPlace $out/bin/startx \
                  --replace-fail '$HOME/.serverauth.$$' ''\'''${XDG_RUNTIME_DIR:-$HOME/.cache}/xserverauth.$$'
              '';
          });
        }
      );
    })
  ];

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
        source /etc/profile
        source ~/.profile
        export SHLVL=1
        export XDG_SESSION_TYPE=x11
        export XAUTHORITY="''${XDG_RUNTIME_DIR}/Xauthority";

        if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
        	eval $(dbus-launch --exit-with-session --sh-syntax)
        fi
        systemctl --user import-environment DISPLAY XAUTHORITY

        if command -v dbus-update-activation-environment &> /dev/null; then
          dbus-update-activation-environment DISPLAY XAUTHORITY
        fi
      '';
  };
}
