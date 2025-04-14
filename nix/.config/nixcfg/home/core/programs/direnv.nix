{ lib, ... }:

{
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
}
