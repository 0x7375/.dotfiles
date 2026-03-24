{
  flake.nixos.pearlman =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      services.logind.settings.Login.HandleLidSwitch = "ignore";
      powerManagement.cpuFreqGovernor = "performance";

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-vaapi-driver
        ];
      };

      users.users.${config.me.user}.openssh.authorizedKeys.keys = config.me.hosts.mach.sshPublicKeys;

      security.pam.services = lib.genAttrs [ "sudo" "su" "polkit-1" "login" ] (_: {
        unixAuth = lib.mkForce true;
      });

      boot.kernelParams = [ "consoleblank=60" ];

      # because bios settings are unreliable
      services.timesyncd.servers = [
        "162.159.200.1" # Cloudflare NTP
        "216.239.35.0" # Google NTP
      ];

      boot.tmp.tmpfsSize = "512M";

      virtualisation.containers.storage.settings.storage = {
        driver = "overlay";
        graphroot = "/mnt/ssd/containers/storage";
        runroot = "/run/containers/storage";
      };

      packages = with pkgs; [ ncdu ];

      services.journald.extraConfig = ''
        SystemMaxFileSize=40M
        SystemMaxUse=200M
      '';

      system.stateVersion = "25.11";
    };
}
