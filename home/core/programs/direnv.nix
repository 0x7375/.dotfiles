{
  config,
  pkgs,
  lib,
  ...
}:

{
  # https://nixpk.gs/pr-tracker.html?pr=401705
  nixpkgs.overlays = lib.optionals (config.me.hostname != "hikari") [
    (final: prev: {
      devenv = prev.devenv.override (old: {
        rustPlatform = old.rustPlatform // {
          buildRustPackage =
            args:
            old.rustPlatform.buildRustPackage (
              args
              // rec {
                version = "v1.6";
                src = pkgs.fetchFromGitHub {
                  owner = "cachix";
                  repo = "devenv";
                  rev = version;
                  sha256 = "6zbQPpB0lSLvPw3UIwYAzgdQLF17ae5q9dXM/0SRN+k=";
                };
                cargoHash = "sha256-XS6F/Sp5peJdzAormYPjAA4SJfusMH6PRYIM3Tw5AUw=";
              }
            );
        };
      });
    })
  ];

  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
    stdlib = # bash
      ''
        : "''${XDG_CACHE_HOME:="''${HOME}/.cache"}"
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
            local hash path
            echo "''${direnv_layout_dirs[$PWD]:=$(
                hash="''$(sha1sum - <<< "$PWD" | head -c40)"
                path="''${PWD//[^a-zA-Z0-9]/-}"
                echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
            )}"
        }

        export DIRENV_LOADED=1
      '';
  };

  home.sessionVariables = {
    DIRENV_WARN_TIMEOUT = 0;
  };

  xdg.configFile."zsh/.zshrc".text =
    lib.mkAfter "command -v direnv &> /dev/null && eval \"$(direnv hook zsh)\"";

  home.packages = [
    pkgs.devenv
  ];
}
