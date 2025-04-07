{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  programs = {
    nh.enable = true;
    git.enable = true;

    nix-index-database.comma.enable = true;
    nix-index.enable = true;

    nix-ld = {
      enable = true;
      libraries = [ ];
    };

    zsh = {
      enable = true;
      autosuggestions.enable = true;

      # handled by home manager
      enableCompletion = false;
    };

    appimage = {
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
  };
}
