{ config, lib, ... }:

lib.mkIf config.me.gui.enable {
  nixpkgs.overlays = [
    (final: prev: {
      libvirt = prev.libvirt.overrideAttrs (oldAttrs: {
        postInstall = ''
          ${oldAttrs.postInstall or ""}
          sed -i '/Skipping/d' $out/libexec/libvirt-guests.sh
        '';
      });
    })
  ];

  virtualisation.libvirtd = {
    enable = true;
    shutdownTimeout = 1;
  };
  programs.virt-manager.enable = true;

  users.users.${config.me.user}.extraGroups = [ "libvirtd" ];
}
