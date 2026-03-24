{
  flake.nixos.wm =
    {
      config,
      ...
    }:
    {
      services.getty = {
        autologinOnce = true;
        autologinUser = config.me.user;
        extraArgs = [
          "--noissue"
          "--nonewline"
          "--nohostname"
        ];
      };
    };
}
