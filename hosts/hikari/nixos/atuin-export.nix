{ pkgs, ... }:

{
  systemd.user.services.atuin-export = {
    path = with pkgs; [
      atuin
      gawk
    ];
    script = ''
      set +e
      export ATUIN_SESSION=$(atuin uuid)
      atuin history list --format {command} | awk '!seen[$0]++' > ~/documents/backup/shell_history
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.user.timers.atuin-export = {
    description = "Weekly Atuin history export";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
