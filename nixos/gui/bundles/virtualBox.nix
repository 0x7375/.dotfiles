{ config, lib, ... }:

lib.mkIf config.me.gui.bundles.virtualBox.enable {
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ config.me.user ];
}
