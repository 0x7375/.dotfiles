{
  lib,
  config,
  system,
  inputs,
  ...
}:

lib.mkIf config.me.gui.bundles.gns3.enable {
  environment.systemPackages = [
    inputs.gns3.legacyPackages.${system}.gns3-gui
  ];

  services.gns3-server = {
    enable = true;
    package = inputs.gns3.legacyPackages.${system}.gns3-server;
  };
}
