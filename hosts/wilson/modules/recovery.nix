{ config, pkgs, ... }:

let
  inherit (config.me) host;
in
{
  services.watchdogd.enable = true;
  boot.kernelParams = [
    "bcm2835_wdt.nowayout=1"
    "panic=10"
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

    script = ''
      MARKER="/var/lib/crash-notifier/clean_exit"

      if [ ! -f "$MARKER" ]; then
        for i in {1..10}; do
          if curl --fail --connect-timeout 5 \
            -d "Server crashed, rebooted" \
            http://${host.ips.lan}:8719/status; then
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
