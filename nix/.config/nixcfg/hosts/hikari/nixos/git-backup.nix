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
        remote_url="https://codeberg.org"
        user="0xB0F"
        remote="''${remote_url}/''${user}"
        backup_dir="/home/${config.me.user}/git"
        mkdir -p "$backup_dir"

        repos=$(curl -s "''${remote_url}/api/v1/users/$user/repos" | jq -r '.[].clone_url')
        repos+=("''${remote}/nix-secrets.git")

        for repo in $repos; do
          repo_name=$(basename "$repo" .git)
          repo_dir="$backup_dir/$repo_name"
          
          if [ -d "$repo_dir" ]; then
            cd "$repo_dir"
            git fetch --all --prune
          else
            git clone --bare "$repo" "$repo_dir"
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
