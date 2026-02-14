{ pkgs, ... }:

{
  packages = [ pkgs.libqalculate ];
  hj.xdg.config.files."qalculate/qalc.cfg".text = "calculate_as_you_type=1";
}
