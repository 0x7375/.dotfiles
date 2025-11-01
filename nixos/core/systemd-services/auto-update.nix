{
  lib,
  config,
  pkgs,
  ...
}:

{
  systemd.timers.auto-input = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  systemd.services.auto-input = {
    serviceConfig = {
      Type = "oneshot";
      User = config.me.user;
      ExecStart = ''
        ${lib.getExe pkgs.nix} flake update auto-update --flake ${config.me.flakeDir}
        ${lib.getExe pkgs.nix} flake update zen-browser --flake ${config.me.flakeDir}
        [[ -d "$HOME/repos/nixpkgs" ]] && git -C "$HOME/repos/nixpkgs" pull
        [[ -d "$HOME/repos/home-manager" ]] && git -C "$HOME/repos/home-manager" pull
      '';
    };
    path = [ pkgs.git ];
  };
}
