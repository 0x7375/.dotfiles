{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (config.me) hostname;
  mkHostSecret = lib.my.mkHostSecret hostname;
in
lib.mkIf config.me.secrets.enable {
  sops.secrets."qbittorrent/pw" = mkHostSecret "qbittorrent/pw" {
    owner = config.services.qbittorrent.user;
  };

  systemd.services.jellyfin-torrent-controller = {
    description = "Automatically pause torrents when starting jellyfin playback";
    after = [
      "network.target"
      "qbittorrent.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      LoadCredential = [ "qb-password:${config.sops.secrets."qbittorrent/pw".path}" ];
      ExecStart =
        pkgs.writers.writePython3 "jellyfin-webhook"
          {
            libraries = with pkgs.python3Packages; [
              flask
              requests
            ];
          }
          ''
            from flask import Flask, request
            import requests
            import threading
            import os

            app = Flask(__name__)

            QBITTORRENT_URL = "http://localhost:${toString config.services.qbittorrent.webuiPort}"
            QB_USERNAME = "admin"
            RESUME_DELAY_SECONDS = 120
            resume_timer = None

            with open(os.environ['CREDENTIALS_DIRECTORY'] + '/qb-password', 'r') as f:
                QB_PASSWORD = f.read().strip()


            def qb_request(endpoint, data):
                """Make authenticated request to qBittorrent API"""
                session = requests.Session()
                session.post(f"{QBITTORRENT_URL}/api/v2/auth/login",
                             data={"username": QB_USERNAME, "password": QB_PASSWORD})
                return session.post(f"{QBITTORRENT_URL}/api/v2/{endpoint}", data=data)


            def pause_torrents():
                try:
                    qb_request("torrents/stop", {"hashes": "all"})
                    print("Torrents paused")
                except Exception as e:
                    print(f"Error pausing: {e}")


            def resume_torrents():
                try:
                    qb_request("torrents/start", {"hashes": "all"})
                    print("Torrents resumed")
                except Exception as e:
                    print(f"Error resuming: {e}")


            def schedule_resume():
                global resume_timer
                resume_timer = threading.Timer(RESUME_DELAY_SECONDS, resume_torrents)
                resume_timer.start()
                print(f"Resume scheduled in {RESUME_DELAY_SECONDS}s")


            @app.route('/', methods=['POST'])
            def webhook():
                try:
                    event = request.json.get('NotificationType')
                    print(f"Event: {event}")

                    if resume_timer:
                        resume_timer.cancel()

                    if event == 'PlaybackStart':
                        pause_torrents()
                    elif event == 'PlaybackStop':
                        schedule_resume()

                    return ''', 200
                except Exception as e:
                    print(f"Error: {e}")
                    return ''', 400


            if __name__ == '__main__':
                app.run(host='0.0.0.0', port=5000)
          '';
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
