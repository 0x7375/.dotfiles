{ config, pkgs, ... }:

{
  systemd.services.git-backup = {
    description = "clone and update git repositories";
    path = with pkgs; [
      git
      coreutils
      curl
      jq
    ];
    script =
      # bash
      ''
        declare -r REMOTE_URL="https://codeberg.org"
        declare -r USER="0xB0F"
        declare -r REMOTE="''${REMOTE_URL}/''${USER}"
        declare -r BACKUP_DIR="/home/${config.me.user}/git"
        mkdir -p "$BACKUP_DIR"

        declare -a REPOS=$(curl -s "''${REMOTE_URL}/api/v1/users/$USER/repos" | jq -r '.[].clone_url')
        REPOS+=("''${REMOTE}/nix-secrets.git")

        for REPO in $REPOS; do
          declare -r REPO_NAME=$(basename "$REPO" .git)
          declare -r REPO_DIR="$BACKUP_DIR/$REPO_NAME"
          
          if [ -d "$REPO_DIR" ]; then
            cd "$REPO_DIR"
            git fetch --all --prune
          else
            git clone --bare "$REPO" "$REPO_DIR"
          fi
        done
      '';
    serviceConfig = {
      Type = "oneshot";
      User = config.me.user;
    };
  };

  systemd.timers.git-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
