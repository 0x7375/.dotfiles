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
    script = ''
      nix flake update auto-update --flake ${config.me.flakeDir}
      nix flake update zen-browser --flake ${config.me.flakeDir}
      [[ -d "$HOME/repos/nixpkgs" ]] && git -C "$HOME/repos/nixpkgs" pull
      [[ -d "$HOME/repos/home-manager" ]] && git -C "$HOME/repos/home-manager" pull
    '';
    serviceConfig = {
      Type = "oneshot";
      User = config.me.user;
    };
    path = [ pkgs.git ];
  };
}
