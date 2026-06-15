{
  flake.modules.nixos.desktop =
    {
      config,
      pkgs,
      ...
    }:
    {
      services.getty = {
        autologinOnce = true;
        autologinUser = config.me.user;
        extraArgs = [
          "--nonewline"
          "--nohostname"
        ];
      };

      environment.etc.issue.source = pkgs.writeText "issue" ''

        <<< \n (\m) - \l >>>

      '';
    };
}
