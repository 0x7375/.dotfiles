{
  mkNixos,
  config,
  lib,
  ...
}:

{
  options.me.wm.optional.virtualBox.enable = lib.mkEnableOption "Enable virtual box";

  config = lib.mkIf config.me.wm.optional.virtualBox.enable (mkNixos {
    virtualisation.virtualbox.host.enable = true;
    users.extraGroups.vboxusers.members = [ config.me.user ];
  });
}
