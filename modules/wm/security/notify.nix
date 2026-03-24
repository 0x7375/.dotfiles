{
  flake.nixos.wm =
    {
      pkgs,
      lib,
      ...
    }:
    {
      systemd.packages = [ pkgs.yubikey-touch-detector ];

      systemd.user.services.yubikey-touch-detector = {
        path = [ pkgs.gnupg ];
        environment = {
          YUBIKEY_TOUCH_DETECTOR_LIBNOTIFY = "false";
          YUBIKEY_TOUCH_DETECTOR_NOSOCKET = "false";
        };
        serviceConfig.ExecStartPost = pkgs.writeShellScript "yubikey-notify" ''
          (${lib.getExe pkgs.netcat} -U "$XDG_RUNTIME_DIR/yubikey-touch-detector.socket" | \
          while IFS= read -r -n5 msg; do \
            if [[ "$msg" == "U2F_1" ]]; then
              ${lib.getExe pkgs.libnotify} -i key -t 0 "Touch required"
            else
              ${lib.getExe' pkgs.dunst "dunstctl"} close-all
            fi
          done) &
        '';
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
      };

      systemd.user.sockets.yubikey-touch-detector = {
        wantedBy = [ "sockets.target" ];
      };
    };
}
