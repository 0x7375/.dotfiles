{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  config = lib.mkIf config.me.btrfs.enable {
    environment.systemPackages = [ pkgs.btdu ];

    services.btrfs.autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
    };

    # sops key is inside home partition and needed
    # during boot: https://github.com/nix-community/disko/issues/192#issuecomment-2567944604
    fileSystems."/home".neededForBoot = true;
    virtualisation.vmVariantWithDisko = {
      virtualisation.fileSystems."/home".neededForBoot = true;
    };
  };
}
