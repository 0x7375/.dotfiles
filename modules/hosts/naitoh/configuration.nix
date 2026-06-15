{
  flake.modules.nixos.naitoh =
    { config, ... }:
    {
      services.auto-cpufreq.enable = true;

      systemd.services.systemd-suspend.serviceConfig.ExecStart = [
        ""
        "${config.systemd.package}/lib/systemd/systemd-sleep suspend-then-hibernate"
      ];

      systemd.sleep.extraConfig = ''
        HibernateDelaySec=30m
      '';

      # systemd.services.disable-lid-wakeup = {
      #   description = "Disable lid switch as wake source for suspend/hibernate";
      #   wantedBy = [ "multi-user.target" ];
      #   after = [ "multi-user.target" ];
      #   serviceConfig = {
      #     Type = "oneshot";
      #     ExecStart = "${getExe pkgs.bash} -c 'echo LID > /proc/acpi/wakeup'";
      #     RemainAfterExit = true;
      #   };
      # };

      # do not change
      # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
      system.stateVersion = "23.11"; # Did you read the comment?
    };
}
