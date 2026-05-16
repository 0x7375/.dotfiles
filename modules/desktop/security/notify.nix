{ self, ... }:

{
  flake.modules.nixos.desktop =
    {
      pkgs,
      lib,
      ...
    }:
    let
      mkToast = self.lib.noctalia.mkToast { inherit pkgs lib; };
      call = self.lib.noctalia.call { inherit pkgs lib; };
    in
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
              ${mkToast {
                title = "Security key";
                body = "Touch required";
                icon = "fingerprint";
                duration = self.lib.noctalia.infinite;
              }}
            else
              ${call "toast dismiss"}
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
