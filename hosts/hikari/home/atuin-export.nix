{ pkgs, ... }:

{
  systemd.user.services.atuinExport = {
    description = "Export Atuin history";
    script = ''
      ${pkgs.atuin}/bin/atuin history list --format "{command}" > ~/documents/backup/shell_history
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.user.timers.atuinExport = {
    description = "Weekly Atuin history export";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
