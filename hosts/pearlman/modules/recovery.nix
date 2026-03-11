{ config, pkgs, ... }:

{
  services.watchdogd.enable = true;
  boot.kernelParams = [
    "panic=10"
    "iTCO_wdt.nowayout=1"
  ];

  systemd.services.crash-notifier = {
    description = "Notify if previous boot ended in a crash";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "crash-notifier";
    };

    path = with pkgs; [ curl ];

    script =
      let
        inherit (config.me.services.ntfy) url;
      in
      # bash
      ''
        MARKER="/var/lib/crash-notifier/clean_exit"

        if [ ! -f "$MARKER" ]; then
          for i in {1..10}; do
            if curl --fail --connect-timeout 5 \
              -d "Server crashed, rebooted" \
              ${url}/status; then
              break
            fi
            echo "Notification failed. Retrying in 5s..."
            sleep 5
          done
        fi

        rm -f "$MARKER"
      '';

    preStop = ''
      touch /var/lib/crash-notifier/clean_exit
    '';
  };
}
