{
  flake.modules.nixos.desktop =
    {
      pkgs,
      lib,
      ...
    }:
    {
      systemd.packages = [ pkgs.yubikey-touch-detector ];

      systemd.user.services.yubikey-touch-detector = {
        path = with pkgs; [
          gnupg
          glib
        ];
        environment = {
          YUBIKEY_TOUCH_DETECTOR_LIBNOTIFY = "false";
          YUBIKEY_TOUCH_DETECTOR_NOSOCKET = "false";
        };
        serviceConfig.ExecStartPost = pkgs.writeShellScript "yubikey-notify" ''
          (${lib.getExe pkgs.netcat} -U "$XDG_RUNTIME_DIR/yubikey-touch-detector.socket" | \
          while IFS= read -r -n5 msg; do \
            if [[ "$msg" == "U2F_1" ]]; then
              active_panel=$(${lib.getExe pkgs.noctalia} msg status | ${lib.getExe pkgs.jq} -r .activePanelId)
              [[ $active_panel == "polkit" ]] && continue
              NOTIF_ID=$(${lib.getExe pkgs.my.notify} \
                "Security key" \
                "Touch required" \
                -i "fingerprint" \
                -t 0 \
                -h boolean:transient:true \
                -p)
            elif [[ -n "$NOTIF_ID" ]]; then
              gdbus call --session \
                --dest org.freedesktop.Notifications \
                --object-path /org/freedesktop/Notifications \
                --method org.freedesktop.Notifications.CloseNotification \
                "$NOTIF_ID" >/dev/null 2>&1
              NOTIF_ID=""
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
