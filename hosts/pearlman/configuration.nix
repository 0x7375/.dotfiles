{
  pkgs,
  config,
  lib,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./options.nix
  ]
  ++ (lib.my.filesIn ./modules);

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  networking.networkmanager.wifi.powersave = false;
  powerManagement.cpuFreqGovernor = "performance";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = config.me.hosts.yubikey.sshPublicKeys;
  users.users.${config.me.user}.openssh.authorizedKeys.keys = config.me.hosts.mach.sshPublicKeys;

  security.pam.services = lib.genAttrs [ "sudo" "su" "polkit-1" "login" ] (_: {
    unixAuth = lib.mkForce true;
  });

  boot.kernelParams = [ "consoleblank=60" ];

  # because battery is dead so time is wrong
  services.timesyncd.servers = [
    "162.159.200.1" # Cloudflare NTP
    "216.239.35.0" # Google NTP
  ];

  virtualisation.containers.storage.settings.storage = {
    driver = "overlay";
    graphroot = "/data/containers/storage";
    runroot = "/run/containers/storage";
  };

  packages = with pkgs; [
    ncdu
    xclip
  ];

  services.journald.extraConfig = ''
    SystemMaxFileSize=40M
    SystemMaxUse=200M
  '';

  system.stateVersion = "25.11";
}
