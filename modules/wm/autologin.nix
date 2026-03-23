{
  mkNixos,
  lib,
  config,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
  services.getty = {
    autologinOnce = true;
    autologinUser = config.me.user;
    extraArgs = [
      "--noissue"
      "--nonewline"
      "--nohostname"
    ];
  };
})
