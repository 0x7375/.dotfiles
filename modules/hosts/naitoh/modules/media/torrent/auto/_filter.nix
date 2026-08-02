{
  flake.modules.nixos.naitoh =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      ratioFarm = pkgs.writers.writeGoBin "ratio-farm" (builtins.readFile ./ratio-farm.go);
    in
    {
      systemd.services.ratio-farm = {
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe ratioFarm}";
          User = config.services.qbittorrent.user;
        };
      };

      systemd.timers.ratio-farm = {
        description = "Run ratio-farm weekly";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };
    };
}
