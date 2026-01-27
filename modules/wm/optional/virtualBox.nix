{
  mkNixos,
  config,
  lib,
  ...
}:

lib.mkIf config.me.wm.optional.virtualBox.enable (mkNixos {
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ config.me.user ];
})

