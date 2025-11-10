{ config, lib, ... }:

lib.mkIf config.me.desktop.enable {
  virtualisation.libvirtd = {
    enable = true;
    shutdownTimeout = 1;
  };
  programs.virt-manager.enable = true;

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 3;
    };
  };

  users.users.${config.me.user}.extraGroups = [ "libvirtd" ];

  programs.dconf.profiles = {
    user.databases = [
      {
        settings = {
          "org/virt-manager/virt-manager/connections" = {
            autoconnect = [ "qemu:///system" ];
            uris = [ "qemu:///system" ];
          };
        };
      }
    ];
  };
}
