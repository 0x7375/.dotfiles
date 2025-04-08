{ lib, myLib, ... }:

{
  imports = [
    ./options.nix
  ] ++ (myLib.filesIn ../../home);

  programs.lf.keybindings = {
    gh = "cd /mnt/c/Users/ayko";
    gm = lib.mkForce "cd /mnt/c/Users/ayko/Documents";
    gw = "cd /mnt/c/Users/ayko/Downloads";
    gA = "cd /mnt/c/Users/ayko/AppData";
    gC = "cd /mnt/c/Users/ayko/.local/share/chezmoi";
  };
}
