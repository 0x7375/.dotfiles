{ inputs, ... }:

{
  flake.modules.generic.core =
    { pkgs, ... }:
    {
      packages = [ pkgs.my.qalc ];
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.qalc = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;

        package = pkgs.libqalculate;
        flags."-s" = [ "autocalc" ];
      };
    };
}
