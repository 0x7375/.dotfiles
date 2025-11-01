# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
{
  config,
  inputs,
  lib,
  myLib,
  pkgs,
  ...
}:

{
  imports = [
    ./options.nix
    inputs.nixos-wsl.nixosModules.wsl
  ]
  ++ (myLib.filesIn ../../nixos);

  networking.hostName = config.me.hostname;

  packages = with pkgs; [
    xsel
  ];

  wsl.enable = true;
  wsl.defaultUser = config.me.user;
  wsl.wslConf.network.hostname = "kumo";
  wsl.interop.register = true;

  hj.xdg.config.files."lf/lfrc".text = ''
    map gh cd /mnt/c/Users/${config.me.user}
    map gm cd /mnt/c/Users/${config.me.user}/Documents
    map gw cd /mnt/c/Users/${config.me.user}/Downloads
    map gA cd /mnt/c/Users/${config.me.user}/AppData
    map gC cd /mnt/c/Users/${config.me.user}/.local/share/chezmoi
  '';

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
