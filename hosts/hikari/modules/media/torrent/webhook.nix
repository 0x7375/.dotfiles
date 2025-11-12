{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.secrets.enable {
  systemd.services.jellyfin-torrent-controller = {
    description = "Automatically pause torrents when starting jellyfin playback";
    after = [
      "network.target"
      "qbittorrent.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      LoadCredential = [ "qb-password:${config.sops.secrets."hikari/qbittorrent_pw".path}" ];
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
            paused_by_us = set()

            with open(os.environ['CREDENTIALS_DIRECTORY'] + '/qb-password', 'r') as f:
                QB_PASSWORD = f.read().strip()


            def qb_request(endpoint, data):
                """Make authenticated request to qBittorrent API"""
                session = requests.Session()
                session.post(f"{QBITTORRENT_URL}/api/v2/auth/login",
                             data={"username": QB_USERNAME, "password": QB_PASSWORD})
                return session.post(f"{QBITTORRENT_URL}/api/v2/{endpoint}", data=data)


            def pause_torrents():
                global paused_by_us
                try:
                    response = qb_request("torrents/info", {})
                    active_hashes = [t['hash'] for t in response.json()
                                     if t['state'] not in ['stoppedUP', 'stoppedDL']]

                    qb_request("torrents/stop", {"hashes": "all"})

                    paused_by_us = set(active_hashes)
                    print(f"Paused {len(active_hashes)} torrents")
                except Exception as e:
                    print(f"Error pausing: {e}")


            def resume_torrents():
                global paused_by_us
                try:
                    if paused_by_us:
                        hashes = "|".join(paused_by_us)
                        qb_request("torrents/start", {"hashes": hashes})

                        print(f"Resumed {len(paused_by_us)} torrents")
                        paused_by_us = set()
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
