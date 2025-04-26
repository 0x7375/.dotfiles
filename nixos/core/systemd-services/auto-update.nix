{ config, pkgs, ... }:

{
  systemd.timers."auto-input-timer" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      Unit = "auto-input.service";
    };
  };

  systemd.services."auto-input" = {
    script = ''
      ${pkgs.nix}/bin/nix flake update auto-update --flake ${config.me.flakeDir}
      ${pkgs.nix}/bin/nix flake update zen-browser --flake ${config.me.flakeDir}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = config.me.user;
    };
    path = [ pkgs.git ];
  };
}
