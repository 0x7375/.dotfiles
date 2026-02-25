{
  mkNixos,
  config,
  pkgs,
  ...
}:

mkNixos {
  systemd.timers.auto-input = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  systemd.services.auto-input = {
    script = ''
      nix flake update auto-update nur zen-browser --flake ${config.me.flakeDir}
      [[ -d "$HOME/repos/nixpkgs" ]] && git -C "$HOME/repos/nixpkgs" pull
      [[ -d "$HOME/repos/home-manager" ]] && git -C "$HOME/repos/home-manager" pull
      [[ -d "$HOME/repos/nix-darwin" ]] && git -C "$HOME/repos/nix-darwin" pull
      [[ -d "$HOME/repos/nur" ]] && git -C "$HOME/repos/nur" pull
    '';
    serviceConfig = {
      Type = "oneshot";
      User = config.me.user;
    };
    path = [ pkgs.git ];
  };
}
