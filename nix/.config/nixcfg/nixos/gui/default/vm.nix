{ config, lib, ... }:

{
  config = lib.mkIf config.me.gui.enable {
    virtualisation.libvirtd = {
      enable = true;
      shutdownTimeout = 1;
    };
    programs.virt-manager.enable = true;

    users.users.${config.me.user}.extraGroups = [ "libvirtd" ];
  };
}
