{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.secrets.enable {
  systemd.services.git-backup = {
    path = with pkgs; [
      git
      coreutils
      curl
      jq
      openssh
    ];
    script =
      # bash
      ''
        remote_url="https://codeberg.org"
        user="0x7E"
        remote="''${remote_url}/''${user}"
        backup_dir="/home/${config.me.user}/git"
        mkdir -p "$backup_dir"

        repos=$(curl -s "''${remote_url}/api/v1/users/$user/repos" | jq -r '.[].clone_url')
        repos+=$'\n'"''${remote}/nix-secrets.git"

        for repo in $repos; do
          repo_name=$(basename "$repo" .git)
          repo_dir="$backup_dir/$repo_name"
          
          if [[ -d $repo_dir ]]; then
            cd "$repo_dir"
            git fetch --all --prune
          else
            git clone --bare "codeberg:$user/$repo_name" "$repo_dir"
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
