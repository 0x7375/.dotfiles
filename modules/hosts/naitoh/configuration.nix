{
  flake.modules.nixos.naitoh =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      # conflicts with kde
      # services.auto-cpufreq.enable = true;

      hardware.graphics.enable = true;

      systemd.services.systemd-suspend.serviceConfig.ExecStart = [
        ""
        "${config.systemd.package}/lib/systemd/systemd-sleep suspend-then-hibernate"
      ];

      systemd.sleep.settings.Sleep = {
        HibernateDelaySec = "30m";
      };

      boot.kernelParams = [ "consoleblank=60" ];

      users.users.${config.me.user}.openssh.authorizedKeys.keys = config.me.hosts.mach.sshPublicKeys;

      security.pam.services = lib.genAttrs [ "sudo" "su" "polkit-1" "login" ] (_: {
        unixAuth = lib.mkForce true;
      });

      services.journald.extraConfig = ''
        SystemMaxFileSize=40M
        SystemMaxUse=200M
      '';
    
      # nixpkgs.overlays = [
      #   (final: prev: {
      #     kdePackages = prev.unstable.kdePackages;
      #   })
      # ];

      # unfree-packages = [ "mdk-sdk" ];

      # services.desktopManager.plasma6.enable = true;
      # packages = with pkgs; [
      #   kdePackages.plasma-bigscreen
      #   jellyfin-desktop
      #   fladder
      # ];
      # programs.kdeconnect.enable = true;

      # services.getty.autologinUser = null;

      # services.greetd = {
      #   enable = true;
      #   settings = {
      #     initial_session = {
      #       command = "plasma-bigscreen-wayland";
      #       inherit (config.me) user;
      #     };
      #     default_session = {
      #       command = "plasma-bigscreen-wayland";
      #       inherit (config.me) user;
      #     };
      #   };
      # };

      services.logind.settings.Login.HandleLidSwitch = "ignore";

      # do not change
      # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
      system.stateVersion = "23.11"; # Did you read the comment?
    };
}
