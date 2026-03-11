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
        backup_dir="/data/backups/git"
        mkdir -p "$backup_dir"

        export GIT_SSH_COMMAND="ssh -i /root/.ssh/id_backup_codeberg -o IdentitiesOnly=yes -o StrictHostKeyChecking=no"

        repos=$(curl -s "''${remote_url}/api/v1/users/$user/repos" | jq -r '.[].clone_url')
        repos+=$'\n'"git@codeberg.org:''${user}/nix-secrets.git"

        for repo in $repos; do
          repo_name=$(basename "$repo" .git)
          repo_dir="$backup_dir/$repo_name"
          
          if [[ -d $repo_dir ]]; then
            cd "$repo_dir"
            git fetch --all --prune
          else
            git clone --bare "$repo" "$repo_dir"
          fi
        done
      '';
    serviceConfig.Type = "oneshot";
  };

  systemd.timers.git-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
