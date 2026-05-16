{
  flake.modules.nixos.desktop =
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
