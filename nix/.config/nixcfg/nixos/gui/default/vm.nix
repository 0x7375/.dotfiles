{ config, lib, ... }:

{
  disabledModules = [ "virtualisation/libvirtd.nix" ];

  config = lib.mkIf config.me.gui.enable {

    virtualisation.libvirtd = {
      enable = true;
      # no system hang on shutdown/reboot
      onShutdown = "ignore";
      shutdownTimeout = 1;
    };
    programs.virt-manager.enable = true;

    users.users.${config.me.user}.extraGroups = [ "libvirtd" ];
  };
}
