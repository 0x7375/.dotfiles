{ pkgs, ... }:

{
  programs.nix-ld = {
    enable = true;
    libraries = [ ];
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs =
        pkgs: with pkgs; [
          libepoxy
          brotli
          xdg-user-dirs
        ];
    };
  };
}
