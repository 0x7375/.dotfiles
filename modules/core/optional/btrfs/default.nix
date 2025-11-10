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
    packages = [ pkgs.btdu ];

    environment.shellAliases.btdu = "sudo mkdir /mnt/crypted; sudo mount -o subvol=/ /dev/mapper/crypted /mnt/crypted && sudo ${lib.getExe pkgs.btdu} /mnt/crypted && sudo umount -l /mnt/crypted";

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
